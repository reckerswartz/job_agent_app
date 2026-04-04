module JobScanner
  class GlassdoorScanner < Base
    GLASSDOOR_BASE = "https://www.glassdoor.com/Job/".freeze

    def scan
      listings = try_browser_scan
      if listings.empty?
        Rails.logger.warn("[GlassdoorScanner] Browser required — Glassdoor blocks HTTP requests (Cloudflare)")
      end
      Rails.logger.info("[GlassdoorScanner] Total: #{listings.size} listings")
      listings
    end

    protected

    def build_search_url
      if criteria&.keywords.present?
        keyword_slug = criteria.keywords.downcase.gsub(/\s+/, "-")
        length = criteria.keywords.length
        location_part = criteria.location.present? ? "#{criteria.location.downcase.gsub(/\s+/, '-')}-" : ""
        "#{GLASSDOOR_BASE}#{location_part}#{keyword_slug}-jobs-SRCH_KO0,#{length}.htm"
      elsif job_source.user.profiles.first
        profile = job_source.user.profiles.first
        headline = profile.headline.to_s.downcase.gsub(/\s+/, "-").presence || "software-developer"
        length = profile.headline.to_s.length
        city = profile.contact_field("city").to_s.downcase.gsub(/\s+/, "-")
        location_part = city.present? ? "#{city}-" : ""
        "#{GLASSDOOR_BASE}#{location_part}#{headline}-jobs-SRCH_KO0,#{length}.htm"
      else
        "#{GLASSDOOR_BASE}software-developer-jobs-SRCH_KO0,18.htm"
      end
    end

    def extraction_script
      <<~JS
        (() => {
          const cards = document.querySelectorAll(
            '[data-test="jobListing"], .JobCard_jobCardContainer__arRdm, ' +
            '.react-job-listing, li.react-job-listing'
          );
          return Array.from(cards).slice(0, 25).map(card => {
            const titleEl = card.querySelector(
              '[data-test="job-title"], .JobCard_jobTitle__GLyJ1, ' +
              '.job-title, a.jobLink'
            );
            const companyEl = card.querySelector(
              '[data-test="employer-name"], .EmployerProfile_compactEmployerName__9MGcV, ' +
              '.employer-name, .css-l2wjgv'
            );
            const locationEl = card.querySelector(
              '[data-test="emp-location"], .JobCard_location__Ds9fT, ' +
              '.location, .css-1buaf54'
            );
            const salaryEl = card.querySelector(
              '[data-test="detailSalary"], .JobCard_salaryEstimate__QpbTW, ' +
              '.salary-estimate, .css-1blav4i'
            );
            const linkEl = card.querySelector(
              'a[href*="/job-listing/"], a[href*="/partner/"], a.jobLink'
            ) || titleEl?.closest('a');
            const eaEl = card.querySelector('.easyApply, [data-test="easyApply"]');

            let url = linkEl ? linkEl.href : null;
            if (url && !url.startsWith('http')) url = 'https://www.glassdoor.com' + url;

            const jobId = url ? url.match(/jobListingId=(\d+)/)?.[1] || url.match(/[-_](\d{6,})/)?.[1] : null;

            return {
              title: titleEl ? titleEl.textContent.trim() : null,
              company: companyEl ? companyEl.textContent.trim() : null,
              location: locationEl ? locationEl.textContent.trim() : null,
              salary_range: salaryEl ? salaryEl.textContent.trim() : null,
              url: url,
              easy_apply: !!eaEl,
              external_id: jobId ? ('gd_' + jobId) : null
            };
          }).filter(i => i.title && i.title.length > 0);
        })()
      JS
    end

    def extract_listings(page_data)
      (page_data[:listings] || []).map do |raw|
        raw_sym = raw.is_a?(Hash) ? raw.symbolize_keys : {}
        normalize_listing(raw_sym.merge(source_platform: "glassdoor"))
      end
    end

    def has_next_page?(page_data)
      return false if (page_data[:listings] || []).size < 10
      @session.evaluate("!!document.querySelector('[data-test=\"pagination-next\"], .nextButton, button[aria-label=\"Next\"]')") || false
    end

    def fetch_next_page(page_data)
      clicked = @session.evaluate(<<~JS)
        (() => {
          const btn = document.querySelector('[data-test="pagination-next"], .nextButton, button[aria-label="Next"]');
          if (btn && !btn.disabled) { btn.click(); return true; }
          return false;
        })()
      JS
      return nil unless clicked
      sleep(3)
      raw_listings = @session.evaluate(extraction_script) || []
      return nil if raw_listings.empty?
      { url: @session.current_url, html: @session.snapshot, listings: raw_listings }
    rescue => e
      Rails.logger.error("[GlassdoorScanner] fetch_next_page failed: #{e.message}")
      nil
    end
  end
end
