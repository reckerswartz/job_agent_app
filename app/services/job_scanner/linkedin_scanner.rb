module JobScanner
  class LinkedinScanner < Base
    LINKEDIN_BASE = "https://www.linkedin.com".freeze
    PUBLIC_JOBS_URL = "https://www.linkedin.com/jobs/search/".freeze
    MAX_DETAIL_SCRAPES = 5

    # ── Main entry point ──────────────────────────────────────────────
    # Strategy: try Playwright logged-in session first (personalized
    # results from LinkedIn's algorithm). Fall back to fast HTTP-based
    # public search if browser is unavailable or user is not logged in.
    # ------------------------------------------------------------------
    def scan
      listings = try_logged_in_scan || try_public_scan
      Rails.logger.info("[LinkedinScanner] Total: #{listings.size} listings")
      listings
    end

    protected

    # ── Profile-aware query builder ───────────────────────────────────
    def build_keywords
      return criteria.keywords if criteria&.keywords.present?

      profile = job_source.user.profiles.first
      return nil unless profile

      parts = []
      parts << profile.headline if profile.headline.present?

      # Extract top skills from profile sections
      skills_section = profile.profile_sections.find_by(section_type: "skills")
      if skills_section
        top_skills = skills_section.profile_entries.limit(5).map { |e| e.content["name"] }.compact
        parts.concat(top_skills.first(3))
      end

      # Use current job title from work experience
      work_section = profile.profile_sections.find_by(section_type: "work_experience")
      if work_section
        latest = work_section.profile_entries.first&.content
        parts << latest["title"] if latest&.dig("title").present?
      end

      parts.uniq.first(3).join(" ")
    end

    def build_location
      return criteria.location if criteria&.location.present?

      profile = job_source.user.profiles.first
      return nil unless profile

      city = profile.contact_field("city")
      country = profile.contact_field("country")
      [city, country].reject(&:blank?).join(", ").presence
    end

    def build_search_url
      params = { sortBy: "DD" }
      kw = build_keywords
      loc = build_location

      params[:keywords] = kw if kw.present?
      params[:location] = loc if loc.present?
      params[:f_TPR] = "r604800" # past week

      if criteria
        params[:f_JT] = linkedin_job_type if criteria.job_type.present?
        params[:f_WT] = linkedin_remote_filter if criteria.remote_preference.present? && criteria.remote_preference != "any"
        params[:f_E] = linkedin_experience_filter if criteria.experience_level.present?
      end

      "#{PUBLIC_JOBS_URL}?#{params.to_query}"
    end

    # ── Mode 1: Playwright logged-in session ──────────────────────────
    def try_logged_in_scan
      @session = BrowserSession.new(headless: true)

      @session.navigate("#{LINKEDIN_BASE}/feed/", wait_until: "domcontentloaded")
      sleep(2)

      unless logged_in?
        Rails.logger.info("[LinkedinScanner] Not logged in — skipping browser mode")
        @session.close
        @session = nil
        return nil
      end

      Rails.logger.info("[LinkedinScanner] Logged in — using personalized search")

      search_url = build_search_url
      @session.navigate(search_url, wait_until: "domcontentloaded")
      sleep(3)

      if @session.captcha_detected?
        create_captcha_intervention!
        return []
      end

      # Scroll to load more results
      3.times { scroll_and_wait }

      raw = @session.evaluate(logged_in_extraction_script) || []
      Rails.logger.info("[LinkedinScanner] Browser extracted #{raw.size} listings")

      listings = raw.map { |r| r.is_a?(Hash) ? r.symbolize_keys : {} }
                    .select { |r| r[:title].present? }
                    .map { |r| normalize_listing(r.merge(source_platform: "linkedin")) }

      # Enrich top listings with detail pages while browser is still open
      enrich_via_browser(listings) if listings.any?

      listings
    rescue => e
      Rails.logger.warn("[LinkedinScanner] Browser scan failed: #{e.message}")
      nil
    ensure
      @session&.close
      @session = nil
    end

    # ── Mode 2: HTTP public search (fast fallback) ────────────────────
    def try_public_scan
      search_url = build_search_url
      Rails.logger.info("[LinkedinScanner] HTTP fallback: #{search_url}")

      html = fetch_html(search_url)
      return [] if html.nil?

      raw_listings = parse_public_cards(html)
      Rails.logger.info("[LinkedinScanner] HTTP parsed #{raw_listings.size} listings")

      listings = raw_listings.map { |r| normalize_listing(r.merge(source_platform: "linkedin")) }

      # Enrich top listings via HTTP
      enrich_via_http(listings) if listings.any?

      listings
    end

    private

    # ── Logged-in helpers ─────────────────────────────────────────────
    def logged_in?
      url = @session.current_url.to_s.downcase
      !url.include?("/login") && !url.include?("/authwall") && (url.include?("/feed") || url.include?("/jobs"))
    end

    def scroll_and_wait
      @session.evaluate("window.scrollTo(0, document.body.scrollHeight)")
      sleep(2)
      @session.evaluate(<<~JS)
        (() => {
          const btn = document.querySelector(
            'button[aria-label="See more jobs"], .infinite-scroller__show-more-button'
          );
          if (btn) btn.click();
        })()
      JS
    rescue => e
      Rails.logger.debug("[LinkedinScanner] scroll: #{e.message}")
    end

    def logged_in_extraction_script
      <<~JS
        (() => {
          const cards = document.querySelectorAll(
            '.jobs-search-results__list-item, .job-card-container, ' +
            '.job-card-list, [data-job-id], .scaffold-layout__list-item, ' +
            '.base-card, .base-search-card'
          );
          return Array.from(cards).slice(0, 25).map(card => {
            const t = card.querySelector(
              '.job-card-list__title, .job-card-container__link, ' +
              '.base-search-card__title, h3 a, h3'
            );
            const c = card.querySelector(
              '.job-card-container__primary-description, .artdeco-entity-lockup__subtitle, ' +
              '.base-search-card__subtitle a, h4 a, h4'
            );
            const l = card.querySelector(
              '.job-card-container__metadata-item, .artdeco-entity-lockup__caption, ' +
              '.job-search-card__location'
            );
            const a = card.querySelector('a[href*="/jobs/view/"]') || card.querySelector('a[href*="/jobs/"]');
            const time = card.querySelector('time');
            const ea = card.querySelector('.job-card-container__apply-method, [data-is-easy-apply="true"]');
            let jid = card.getAttribute('data-job-id') || card.getAttribute('data-occludable-job-id');
            if (!jid && a) { const m = a.href.match(/view\\/(\\d+)/); if (m) jid = m[1]; }
            const sal = card.querySelector('.job-card-container__salary-info, .salary-main-rail__data-body');
            return {
              title: t ? t.textContent.trim() : null,
              company: c ? c.textContent.trim() : null,
              location: l ? l.textContent.trim() : null,
              url: a ? a.href.split('?')[0] : null,
              posted_at: time ? time.getAttribute('datetime') : null,
              easy_apply: ea ? ea.textContent.toLowerCase().includes('easy apply') : false,
              external_id: jid ? ('li_' + jid) : null,
              salary_range: sal ? sal.textContent.trim() : null
            };
          }).filter(i => i.title && i.title.length > 0);
        })()
      JS
    end

    def enrich_via_browser(listings)
      listings.first(MAX_DETAIL_SCRAPES).each_with_index do |listing, i|
        next if listing[:url].blank?
        begin
          @session.navigate(listing[:url], wait_until: "domcontentloaded")
          sleep(2)
          details = @session.evaluate(detail_extraction_script) || {}
          details = details.is_a?(Hash) ? details.symbolize_keys : {}
          apply_details(listing, details)
          Rails.logger.info("[LinkedinScanner] Enriched #{i + 1}: #{listing[:title]}")
        rescue => e
          Rails.logger.warn("[LinkedinScanner] Browser enrich failed: #{e.message}")
        end
      end
    end

    def detail_extraction_script
      <<~JS
        (() => {
          const d = document.querySelector('.show-more-less-html__markup, .description__text, .jobs-description__content');
          const btn = document.querySelector('.jobs-apply-button, button[data-control-name*="apply"]');
          const ea = btn ? (btn.textContent.toLowerCase().includes('easy apply') || btn.classList.contains('jobs-apply-button--easy-apply')) : false;
          let appUrl = null;
          if (!ea) {
            const ext = document.querySelector('a[data-control-name*="external_apply"], .jobs-apply-button[href]');
            if (ext && ext.href) appUrl = ext.href;
          }
          const items = document.querySelectorAll('.description__job-criteria-item, .jobs-unified-top-card__job-insight');
          let empType = null, wpType = null;
          items.forEach(el => {
            const lbl = el.querySelector('h3, .description__job-criteria-subheader');
            const val = el.querySelector('span, .description__job-criteria-text');
            if (lbl && val) {
              const lt = lbl.textContent.trim().toLowerCase();
              if (lt.includes('employment') || lt.includes('job type')) empType = val.textContent.trim();
              if (lt.includes('workplace')) wpType = val.textContent.trim();
            }
          });
          return {
            description: d ? d.innerText.trim().substring(0, 3000) : null,
            easy_apply: ea,
            application_url: appUrl,
            employment_type: empType,
            workplace_type: wpType
          };
        })()
      JS
    end

    # ── HTTP helpers (public fallback) ────────────────────────────────
    def fetch_html(url)
      uri = URI(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.read_timeout = 30
      http.open_timeout = 15

      req = Net::HTTP::Get.new(uri)
      req["User-Agent"] = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
      req["Accept"] = "text/html,application/xhtml+xml"
      req["Accept-Language"] = "en-US,en;q=0.5"

      resp = http.request(req)
      Rails.logger.info("[LinkedinScanner] HTTP #{resp.code}")
      resp.code.to_i == 200 ? resp.body : nil
    rescue => e
      Rails.logger.error("[LinkedinScanner] HTTP failed: #{e.message}")
      nil
    end

    def parse_public_cards(html)
      listings = []
      html.scan(/<li[^>]*>(?:(?!<\/li>).)*base-search-card(?:(?!<\/li>).)*<\/li>/m).each do |card|
        l = extract_public_card(card)
        listings << l if l[:title].present?
      end
      listings.first(25)
    end

    def extract_public_card(h)
      title    = h[/class="[^"]*base-search-card__title[^"]*"[^>]*>([^<]+)/m, 1]&.strip || h[/<h3[^>]*>([^<]+)/m, 1]&.strip
      company  = h[/class="[^"]*base-search-card__subtitle[^"]*"[^>]*>\s*<a[^>]*>([^<]+)/m, 1]&.strip ||
                 h[/class="[^"]*hidden-nested-link[^"]*"[^>]*>([^<]+)/m, 1]&.strip
      location = h[/class="[^"]*job-search-card__location[^"]*"[^>]*>([^<]+)/m, 1]&.strip
      url      = h[/href="(https:\/\/www\.linkedin\.com\/jobs\/view\/[^"?]+)/m, 1]
      time     = h[/<time[^>]*datetime="([^"]+)"/m, 1]
      jid      = url&.match(/\/view\/(\d+)/)&.[](1)
      ea       = h.include?("Easy Apply")
      { title: title, company: company, location: location, url: url, posted_at: time,
        external_id: jid ? "li_#{jid}" : nil, easy_apply: ea, salary_range: h[/salary[^"]*"[^>]*>([^<]+)/m, 1]&.strip }
    end

    def enrich_via_http(listings)
      listings.first(MAX_DETAIL_SCRAPES).each_with_index do |listing, i|
        next if listing[:url].blank?
        begin
          dhtml = fetch_html(listing[:url])
          next unless dhtml
          desc = dhtml[/show-more-less-html__markup[^>]*>(.*?)<\/div>/m, 1] ||
                 dhtml[/description__text[^>]*>(.*?)<\/section>/m, 1]
          listing[:description] = desc.gsub(/<[^>]+>/, " ").gsub(/\s+/, " ").strip.truncate(3000) if desc.present?
          listing[:easy_apply] = true if dhtml.include?("Easy Apply")
          listing[:resume_upload_supported] = listing[:easy_apply]
          listing[:remote_type] = detect_remote_type(listing[:location].to_s, dhtml)
          Rails.logger.info("[LinkedinScanner] Enriched #{i + 1}: #{listing[:title]}")
          sleep(1)
        rescue => e
          Rails.logger.warn("[LinkedinScanner] HTTP enrich failed: #{e.message}")
        end
      end
    end

    # ── Shared helpers ────────────────────────────────────────────────
    def apply_details(listing, d)
      listing[:description]             = d[:description] if d[:description].present?
      listing[:easy_apply]              = d[:easy_apply] if d.key?(:easy_apply)
      listing[:application_url]         = d[:application_url] if d[:application_url].present?
      listing[:employment_type]         = d[:employment_type] if d[:employment_type].present?
      listing[:remote_type]             = detect_remote_type(listing[:location].to_s, d[:workplace_type].to_s)
      listing[:resume_upload_supported] = listing[:easy_apply]
    end

    def detect_remote_type(location, extra)
      t = "#{location} #{extra}".downcase
      return "remote" if t.include?("remote")
      return "hybrid" if t.include?("hybrid")
      return "onsite" if t.include?("on-site") || t.include?("onsite")
      nil
    end

    def linkedin_job_type
      { "full_time" => "F", "part_time" => "P", "contract" => "C", "internship" => "I" }[criteria&.job_type] || "F"
    end

    def linkedin_remote_filter
      { "remote" => "2", "hybrid" => "3", "onsite" => "1" }[criteria&.remote_preference]
    end

    def linkedin_experience_filter
      { "entry" => "2", "mid" => "3,4", "senior" => "4", "lead" => "5", "executive" => "6" }[criteria&.experience_level]
    end
  end
end
