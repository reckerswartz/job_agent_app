module JobScanner
  class NaukriScanner < Base
    NAUKRI_BASE = "https://www.naukri.com/".freeze

    protected

    def build_search_url
      if criteria&.keywords.present?
        slug = criteria.keywords.downcase.gsub(/\s+/, "-")
        location_slug = criteria.location.present? ? "-in-#{criteria.location.downcase.gsub(/\s+/, '-')}" : ""
        "#{NAUKRI_BASE}#{slug}-jobs#{location_slug}"
      elsif job_source.user.profiles.first
        profile = job_source.user.profiles.first
        slug = profile.headline.to_s.downcase.gsub(/\s+/, "-").presence || "software-developer"
        city = profile.contact_field("city").to_s.downcase.gsub(/\s+/, "-")
        location_slug = city.present? ? "-in-#{city}" : ""
        "#{NAUKRI_BASE}#{slug}-jobs#{location_slug}"
      else
        NAUKRI_BASE
      end
    end

    def extraction_script
      <<~JS
        Array.from(document.querySelectorAll('.srp-jobtuple-wrapper, .jobTuple, article.jobTuple, [data-job-id]')).slice(0, 25).map(card => {
          const titleEl = card.querySelector('.title, a.title, .row1 a, .jobTitle');
          const companyEl = card.querySelector('.comp-name, .companyInfo a, .row2 .comp-name, .company');
          const locationEl = card.querySelector('.loc-wrap .locWdth, .location, .row4 .loc, .locn');
          const linkEl = card.querySelector('a.title, a[href*="/job-listings"], a.jobTitle') || card.querySelector('a');
          const salaryEl = card.querySelector('.sal-wrap .ni-job-tuple-icon-srp-rupee, .salary, .sal');
          const expEl = card.querySelector('.exp-wrap .expwdth, .experience, .exp');

          const easyApplyEl = card.querySelector('.easyApply, .applyButton .easy-apply, [data-is-easy-apply]');
          const easyApply = !!easyApplyEl;

          const jobId = card.getAttribute('data-job-id') || card.getAttribute('data-jobid');

          return {
            title: titleEl ? titleEl.textContent.trim() : null,
            company: companyEl ? companyEl.textContent.trim() : null,
            location: locationEl ? locationEl.textContent.trim() : null,
            url: linkEl ? linkEl.href : null,
            salary_range: salaryEl ? salaryEl.textContent.trim() : null,
            experience: expEl ? expEl.textContent.trim() : null,
            easy_apply: easyApply,
            external_id: jobId ? ('naukri_' + jobId) : null
          };
        }).filter(item => item.title && item.title.length > 0)
      JS
    end

    def extract_listings(page_data)
      (page_data[:listings] || []).map do |raw|
        raw_sym = raw.is_a?(Hash) ? raw.symbolize_keys : {}
        normalize_listing(raw_sym.merge(source_platform: "naukri"))
      end
    end

    def has_next_page?(page_data)
      return false if (page_data[:listings] || []).size < 10
      @session.evaluate("!!document.querySelector('.fright.fs14.btn-secondary.br2, a.fright, a[data-ga-track=\"spa-event|pagination|next\"]')") || false
    end

    def fetch_next_page(page_data)
      clicked = @session.evaluate(<<~JS)
        (() => {
          const next = document.querySelector('.fright.fs14.btn-secondary.br2, a.fright, a[data-ga-track="spa-event|pagination|next"]');
          if (next) { next.click(); return true; }
          return false;
        })()
      JS
      return nil unless clicked
      sleep(3)
      raw_listings = @session.evaluate(extraction_script) || []
      return nil if raw_listings.empty?
      { url: @session.current_url, html: @session.snapshot, listings: raw_listings }
    rescue => e
      Rails.logger.error("[NaukriScanner] fetch_next_page failed: #{e.message}")
      nil
    end
  end
end
