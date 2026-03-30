module JobScanner
  class LinkedinScanner < Base
    LINKEDIN_BASE = "https://www.linkedin.com".freeze
    PUBLIC_JOBS_BASE = "https://www.linkedin.com/jobs/search/".freeze
    LOGGED_IN_JOBS_BASE = "https://www.linkedin.com/jobs/search/".freeze
    MAX_DETAIL_SCRAPES = 10

    def scan
      listings = []
      @session = BrowserSession.new

      # Navigate to LinkedIn first to check login state
      @session.navigate("#{LINKEDIN_BASE}/feed/")
      sleep(2)

      @logged_in = !@session.login_required?
      Rails.logger.info("[LinkedinScanner] Logged in: #{@logged_in}")

      if !@logged_in
        # Try public job search (no login required for basic listings)
        Rails.logger.info("[LinkedinScanner] Using public job search (not logged in)")
      end

      search_url = build_search_url
      page_data = fetch_page(search_url)
      return listings if page_data.nil?

      # After navigating to search, check again for auth walls
      if @session.login_required? && !@logged_in
        # Public search still works on LinkedIn without login for basic results
        # Only create intervention if we get NO results
        if (page_data[:listings] || []).empty?
          create_login_intervention!
          return listings
        end
      end

      if @session.captcha_detected?
        create_captcha_intervention!
        return listings
      end

      MAX_PAGES.times do |page_num|
        page_listings = extract_listings(page_data)
        listings.concat(page_listings)

        break unless has_next_page?(page_data)
        break if page_num >= MAX_PAGES - 1

        page_data = fetch_next_page(page_data, page_num + 1)
        break if page_data.nil?
      end

      # Scrape job detail pages for descriptions, easy apply detection
      listings = enrich_with_details(listings)

      listings
    ensure
      @session&.close
    end

    protected

    def build_search_url
      params = { sortBy: "DD" }

      if criteria
        params[:keywords] = criteria.keywords if criteria.keywords.present?
        params[:location] = criteria.location if criteria.location.present?
        params[:f_TPR] = time_filter
        params[:f_JT] = linkedin_job_type if criteria.job_type.present?
        params[:f_WT] = linkedin_remote_filter if criteria.remote_preference.present? && criteria.remote_preference != "any"
      elsif job_source.user.profiles.first
        # Build query from user profile if no explicit criteria
        profile = job_source.user.profiles.first
        params[:keywords] = profile.headline if profile.headline.present?
        params[:location] = profile.contact_field("city") if profile.contact_field("city").present?
      end

      "#{PUBLIC_JOBS_BASE}?#{params.to_query}"
    end

    def extraction_script
      <<~JS
        (() => {
          // LinkedIn has different DOM structures for public vs logged-in views
          const selectors = [
            // Public job search cards
            '.base-card, .job-search-card, .base-search-card',
            // Logged-in job cards
            '.jobs-search-results__list-item, .job-card-container, [data-job-id]',
            // Fallback
            '[data-tracking-control-name="public_jobs_jserp-result"]'
          ].join(', ');

          return Array.from(document.querySelectorAll(selectors)).slice(0, 25).map(card => {
            // Title
            const titleEl = card.querySelector(
              '.base-search-card__title, .job-search-card__title, ' +
              '.job-card-list__title, .artdeco-entity-lockup__title, ' +
              'h3, a[data-control-name="job_card_title"]'
            );

            // Company
            const companyEl = card.querySelector(
              '.base-search-card__subtitle, .job-search-card__company-name, ' +
              '.job-card-container__primary-description, .artdeco-entity-lockup__subtitle, ' +
              'h4, a[data-control-name="job_card_company"]'
            );

            // Location
            const locationEl = card.querySelector(
              '.job-search-card__location, .base-search-card__metadata, ' +
              '.job-card-container__metadata-item, .artdeco-entity-lockup__caption, ' +
              '.job-card-container__metadata-wrapper'
            );

            // Link
            const linkEl = card.querySelector('a[href*="/jobs/view/"]') ||
                           card.querySelector('a[href*="/jobs/"]') ||
                           card.querySelector('a');

            // Posted time
            const timeEl = card.querySelector('time');
            const timeText = card.querySelector('.job-search-card__listdate, .job-card-container__footer-item');

            // Easy Apply badge
            const easyApplyEl = card.querySelector(
              '.job-card-container__apply-method, .result-benefits__text, ' +
              '[data-is-easy-apply="true"], .job-search-card__easy-apply-label'
            );
            const easyApply = easyApplyEl ?
              easyApplyEl.textContent.toLowerCase().includes('easy apply') : false;

            // Job ID from data attribute or URL
            let jobId = card.getAttribute('data-job-id') ||
                        card.getAttribute('data-entity-urn');
            if (!jobId && linkEl) {
              const match = linkEl.href.match(/\/jobs\/view\/(\d+)/);
              if (match) jobId = match[1];
            }

            // Salary info
            const salaryEl = card.querySelector(
              '.job-search-card__salary-info, .job-card-container__salary-info, ' +
              '.salary-main-rail__data-body'
            );

            return {
              title: titleEl ? titleEl.textContent.trim() : null,
              company: companyEl ? companyEl.textContent.trim() : null,
              location: locationEl ? locationEl.textContent.trim() : null,
              url: linkEl ? linkEl.href.split('?')[0] : null,
              posted_at: timeEl ? timeEl.getAttribute('datetime') : (timeText ? timeText.textContent.trim() : null),
              easy_apply: easyApply,
              external_id: jobId ? ('li_' + jobId) : null,
              salary_range: salaryEl ? salaryEl.textContent.trim() : null
            };
          }).filter(item => item.title && item.title.length > 0);
        })()
      JS
    end

    def extract_listings(page_data)
      (page_data[:listings] || []).map do |raw|
        raw_sym = raw.is_a?(Hash) ? raw.symbolize_keys : {}
        normalize_listing(raw_sym.merge(source_platform: "linkedin"))
      end
    end

    def has_next_page?(page_data)
      return false if (page_data[:listings] || []).size < 10

      @session.evaluate(<<~JS) || false
        !!document.querySelector(
          'button[aria-label="See more jobs"], ' +
          '.infinite-scroller__show-more-button, ' +
          'button.see-more-jobs, ' +
          '.jobs-search-results-list__pagination button[aria-label*="Page"]'
        )
      JS
    end

    def fetch_next_page(page_data, page_num)
      # LinkedIn uses either infinite scroll or pagination
      scrolled = @session.evaluate(<<~JS)
        (() => {
          // Try clicking "See more jobs" button
          const moreBtn = document.querySelector(
            'button[aria-label="See more jobs"], ' +
            '.infinite-scroller__show-more-button, ' +
            'button.see-more-jobs'
          );
          if (moreBtn) { moreBtn.click(); return 'clicked'; }

          // Scroll to bottom for infinite scroll
          window.scrollTo(0, document.body.scrollHeight);
          return 'scrolled';
        })()
      JS

      return nil unless scrolled
      sleep(3) # Wait for new results to load

      raw_listings = @session.evaluate(extraction_script) || []
      # Filter to only new listings (skip ones we already have from previous pages)
      existing_count = page_data[:listings]&.size || 0
      new_listings = raw_listings[existing_count..] || []

      return nil if new_listings.empty?

      { url: @session.current_url, html: @session.snapshot, listings: new_listings }
    rescue => e
      Rails.logger.error("[LinkedinScanner] fetch_next_page failed: #{e.message}")
      nil
    end

    private

    def enrich_with_details(listings)
      listings.first(MAX_DETAIL_SCRAPES).each_with_index do |listing, i|
        next if listing[:url].blank?

        begin
          @session.navigate(listing[:url])
          sleep(2)

          details = @session.evaluate(job_detail_script) || {}
          details = details.is_a?(Hash) ? details.symbolize_keys : {}

          listing[:description] = details[:description].to_s.strip.presence if details[:description].present?
          listing[:requirements] = details[:requirements].to_s.strip.presence if details[:requirements].present?
          listing[:easy_apply] = details[:easy_apply] if details.key?(:easy_apply)
          listing[:application_url] = details[:application_url].to_s.strip.presence if details[:application_url].present?
          listing[:employment_type] = details[:employment_type].to_s.strip.presence if details[:employment_type].present?
          listing[:remote_type] = detect_remote_type(listing[:location].to_s, details[:workplace_type].to_s)
          listing[:resume_upload_supported] = listing[:easy_apply] # Easy Apply typically supports resume upload

          Rails.logger.info("[LinkedinScanner] Enriched #{i + 1}/#{[listings.size, MAX_DETAIL_SCRAPES].min}: #{listing[:title]}")
        rescue => e
          Rails.logger.warn("[LinkedinScanner] Detail scrape failed for #{listing[:url]}: #{e.message}")
        end
      end

      listings
    end

    def job_detail_script
      <<~JS
        (() => {
          // Description
          const descEl = document.querySelector(
            '.show-more-less-html__markup, .description__text, ' +
            '.jobs-description__content, .jobs-box__html-content, ' +
            '[data-job-description]'
          );

          // Apply button analysis
          const applyBtn = document.querySelector(
            '.jobs-apply-button, .jobs-apply-button--top-card, ' +
            'button[data-control-name="jobdetails_topcard_inapply"], ' +
            '.jobs-s-apply button'
          );
          const easyApply = applyBtn ?
            (applyBtn.textContent.toLowerCase().includes('easy apply') ||
             applyBtn.classList.contains('jobs-apply-button--easy-apply')) : false;

          // External application URL
          let applicationUrl = null;
          const externalLink = document.querySelector(
            'a[data-control-name="jobdetails_topcard_external_apply"], ' +
            '.jobs-apply-button[href], a.jobs-apply-button'
          );
          if (externalLink && externalLink.href && !easyApply) {
            applicationUrl = externalLink.href;
          }

          // Job criteria (employment type, seniority, etc.)
          const criteriaItems = document.querySelectorAll(
            '.description__job-criteria-item, .jobs-unified-top-card__job-insight, ' +
            '.job-criteria__item'
          );
          let employmentType = null;
          let workplaceType = null;
          criteriaItems.forEach(item => {
            const label = item.querySelector('.description__job-criteria-subheader, h3');
            const value = item.querySelector('.description__job-criteria-text, span');
            if (label && value) {
              const labelText = label.textContent.trim().toLowerCase();
              if (labelText.includes('employment type') || labelText.includes('job type')) {
                employmentType = value.textContent.trim();
              }
              if (labelText.includes('workplace') || labelText.includes('job location')) {
                workplaceType = value.textContent.trim();
              }
            }
          });

          return {
            description: descEl ? descEl.innerText.trim() : null,
            requirements: null,
            easy_apply: easyApply,
            application_url: applicationUrl,
            employment_type: employmentType,
            workplace_type: workplaceType
          };
        })()
      JS
    end

    def detect_remote_type(location, workplace_type)
      combined = "#{location} #{workplace_type}".downcase
      if combined.include?("remote")
        "remote"
      elsif combined.include?("hybrid")
        "hybrid"
      elsif combined.include?("on-site") || combined.include?("onsite")
        "onsite"
      end
    end

    def linkedin_job_type
      case criteria&.job_type
      when "full_time" then "F"
      when "part_time" then "P"
      when "contract"  then "C"
      when "internship" then "I"
      else "F"
      end
    end

    def linkedin_remote_filter
      case criteria&.remote_preference
      when "remote" then "2"
      when "hybrid" then "3"
      when "onsite" then "1"
      end
    end

    def time_filter
      "r604800" # past week
    end
  end
end
