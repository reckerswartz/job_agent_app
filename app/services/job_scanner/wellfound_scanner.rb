module JobScanner
  class WellfoundScanner < Base
    WELLFOUND_BASE = "https://wellfound.com/role/r/".freeze

    def scan
      listings = try_browser_scan
      if listings.empty?
        Rails.logger.warn("[WellfoundScanner] Browser required — Wellfound blocks HTTP requests (Cloudflare)")
      end
      Rails.logger.info("[WellfoundScanner] Total: #{listings.size} listings")
      listings
    end

    protected

    def build_search_url
      if criteria&.keywords.present?
        slug = criteria.keywords.downcase.gsub(/\s+/, "-")
        "#{WELLFOUND_BASE}#{slug}"
      elsif job_source.user.profiles.first
        profile = job_source.user.profiles.first
        slug = profile.headline.to_s.downcase.gsub(/\s+/, "-").presence || "software-developer"
        "#{WELLFOUND_BASE}#{slug}"
      else
        "#{WELLFOUND_BASE}software-developer"
      end
    end

    def extraction_script
      <<~JS
        (() => {
          const cards = document.querySelectorAll(
            '[data-test="StartupResult"], .styles_listItem__hBrgj, ' +
            '.styles_result__rPRNG, [class*="JobListingCard"], ' +
            '[class*="StartupResult"]'
          );
          return Array.from(cards).slice(0, 25).map(card => {
            const titleEl = card.querySelector(
              '[class*="styles_title"], [class*="jobTitle"], ' +
              'h2 a, a[class*="JobTitle"]'
            );
            const companyEl = card.querySelector(
              '[class*="styles_startupName"], [class*="companyName"], ' +
              'h3 a, a[class*="StartupName"]'
            );
            const locationEl = card.querySelector(
              '[class*="styles_location"], [class*="location"], ' +
              'span[class*="Location"]'
            );
            const salaryEl = card.querySelector(
              '[class*="compensation"], [class*="salary"], ' +
              'span[class*="Compensation"]'
            );
            const linkEl = card.querySelector(
              'a[href*="/jobs/"], a[href*="/role/"]'
            ) || titleEl?.closest('a');

            let url = linkEl ? linkEl.href : null;
            if (url && !url.startsWith('http')) url = 'https://wellfound.com' + url;

            const tags = Array.from(card.querySelectorAll('[class*="tag"], [class*="badge"], span[class*="Tag"]'))
              .map(t => t.textContent.trim());
            const isRemote = tags.some(t => t.toLowerCase().includes('remote'));

            const jobId = url ? url.match(/\/(\d+)$/)?.[1] : null;

            return {
              title: titleEl ? titleEl.textContent.trim() : null,
              company: companyEl ? companyEl.textContent.trim() : null,
              location: locationEl ? locationEl.textContent.trim() : null,
              salary_range: salaryEl ? salaryEl.textContent.trim() : null,
              url: url,
              remote_type: isRemote ? 'remote' : null,
              external_id: jobId ? ('wf_' + jobId) : null
            };
          }).filter(i => i.title && i.title.length > 0);
        })()
      JS
    end

    def extract_listings(page_data)
      (page_data[:listings] || []).map do |raw|
        raw_sym = raw.is_a?(Hash) ? raw.symbolize_keys : {}
        normalize_listing(raw_sym.merge(source_platform: "wellfound"))
      end
    end

    def has_next_page?(page_data)
      return false if (page_data[:listings] || []).size < 10
      @session.evaluate("!!document.querySelector('button[class*=\"LoadMore\"], a[class*=\"next\"], button:has-text(\"Load more\")')") || false
    end

    def fetch_next_page(page_data)
      clicked = @session.evaluate(<<~JS)
        (() => {
          const btn = document.querySelector('button[class*="LoadMore"], a[class*="next"]');
          if (btn) { btn.click(); return true; }
          return false;
        })()
      JS
      return nil unless clicked
      sleep(3)
      raw_listings = @session.evaluate(extraction_script) || []
      return nil if raw_listings.empty?
      { url: @session.current_url, html: @session.snapshot, listings: raw_listings }
    rescue => e
      Rails.logger.error("[WellfoundScanner] fetch_next_page failed: #{e.message}")
      nil
    end
  end
end
