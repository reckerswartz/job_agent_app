module JobScanner
  class LinkedinScanner < Base
    LINKEDIN_BASE = "https://www.linkedin.com".freeze
    PUBLIC_JOBS_BASE = "https://www.linkedin.com/jobs/search/".freeze
    LOGGED_IN_JOBS_BASE = "https://www.linkedin.com/jobs/search/".freeze
    MAX_DETAIL_SCRAPES = 5

    def scan
      listings = []

      search_url = build_search_url
      Rails.logger.info("[LinkedinScanner] Fetching: #{search_url}")

      # Use direct HTTP fetch for public LinkedIn job search (much faster than headless browser)
      html = fetch_html(search_url)
      return listings if html.nil?

      # Parse job cards from HTML using regex (no JS evaluation needed)
      raw_listings = parse_job_cards(html)
      Rails.logger.info("[LinkedinScanner] Parsed #{raw_listings.size} listings from HTML")

      raw_listings.each do |raw|
        listings << normalize_listing(raw.merge(source_platform: "linkedin"))
      end

      listings
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

    def fetch_html(url)
      uri = URI(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.read_timeout = 30
      http.open_timeout = 15

      request = Net::HTTP::Get.new(uri)
      request["User-Agent"] = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
      request["Accept"] = "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"
      request["Accept-Language"] = "en-US,en;q=0.5"

      response = http.request(request)
      Rails.logger.info("[LinkedinScanner] HTTP #{response.code} for #{url}")

      if response.code.to_i == 200
        response.body
      elsif response.code.to_i == 429
        Rails.logger.warn("[LinkedinScanner] Rate limited (429)")
        nil
      else
        Rails.logger.warn("[LinkedinScanner] HTTP #{response.code}")
        nil
      end
    rescue => e
      Rails.logger.error("[LinkedinScanner] fetch_html failed: #{e.message}")
      nil
    end

    def parse_job_cards(html)
      listings = []

      # LinkedIn public search returns <li> elements containing base-search-card class
      html.scan(/<li[^>]*>(?:(?!<\/li>).)*base-search-card(?:(?!<\/li>).)*<\/li>/m).each do |card_html|
        listing = extract_from_card(card_html)
        listings << listing if listing[:title].present?
      end

      listings.first(25)
    end

    def extract_from_card(card_html)
      title = card_html[/class="[^"]*base-search-card__title[^"]*"[^>]*>([^<]+)/m, 1]&.strip
      title ||= card_html[/<h3[^>]*>([^<]+)/m, 1]&.strip
      title ||= card_html[/class="[^"]*job-search-card__title[^"]*"[^>]*>([^<]+)/m, 1]&.strip

      company = card_html[/class="[^"]*base-search-card__subtitle[^"]*"[^>]*>\s*<a[^>]*>([^<]+)/m, 1]&.strip
      company ||= card_html[/class="[^"]*hidden-nested-link[^"]*"[^>]*>([^<]+)/m, 1]&.strip
      company ||= card_html[/class="[^"]*base-search-card__subtitle[^"]*"[^>]*>([^<]+)/m, 1]&.strip
      company ||= card_html[/<h4[^>]*>([^<]+)/m, 1]&.strip

      location = card_html[/class="[^"]*job-search-card__location[^"]*"[^>]*>([^<]+)/m, 1]&.strip

      url = card_html[/href="(https:\/\/www\.linkedin\.com\/jobs\/view\/[^"?]+)/m, 1]
      url ||= card_html[/href="(https:\/\/[^"]*linkedin[^"]*jobs[^"?]+)/m, 1]

      posted_at = card_html[/<time[^>]*datetime="([^"]+)"/m, 1]

      job_id = url&.match(/\/jobs\/view\/(\d+)/)&.[](1)

      salary = card_html[/class="[^"]*salary[^"]*"[^>]*>([^<]+)/m, 1]&.strip

      easy_apply = card_html.include?("Easy Apply") || card_html.include?("easy-apply")

      {
        title: title,
        company: company,
        location: location,
        url: url,
        posted_at: posted_at,
        external_id: job_id ? "li_#{job_id}" : nil,
        salary_range: salary,
        easy_apply: easy_apply
      }
    end

    def enrich_with_details(listings)
      listings.first(MAX_DETAIL_SCRAPES).each_with_index do |listing, i|
        next if listing[:url].blank?

        begin
          detail_html = fetch_html(listing[:url])
          next if detail_html.nil?

          # Extract description from detail page HTML
          desc = detail_html[/class="[^"]*show-more-less-html__markup[^"]*"[^>]*>(.*?)<\/div>/m, 1]
          desc ||= detail_html[/class="[^"]*description__text[^"]*"[^>]*>(.*?)<\/section>/m, 1]
          if desc.present?
            listing[:description] = desc.gsub(/<[^>]+>/, " ").gsub(/\s+/, " ").strip.truncate(3000)
          end

          # Check for Easy Apply
          listing[:easy_apply] = true if detail_html.include?("Easy Apply")
          listing[:resume_upload_supported] = listing[:easy_apply]

          # Detect remote type from detail page
          listing[:remote_type] = detect_remote_type(listing[:location].to_s, detail_html)

          Rails.logger.info("[LinkedinScanner] Enriched #{i + 1}/#{[listings.size, MAX_DETAIL_SCRAPES].min}: #{listing[:title]}")
          sleep(1) # Rate limit between detail page fetches
        rescue => e
          Rails.logger.warn("[LinkedinScanner] Detail fetch failed for #{listing[:url]}: #{e.message}")
        end
      end

      listings
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
