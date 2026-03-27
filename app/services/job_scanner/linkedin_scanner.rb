module JobScanner
  class LinkedinScanner < Base
    protected

    def build_search_url
      base = "https://www.linkedin.com/jobs/search/"
      params = { sortBy: "DD" }
      if criteria
        params[:keywords] = criteria.keywords if criteria.keywords.present?
        params[:location] = criteria.location if criteria.location.present?
        params[:f_TPR] = "r604800" # past week
        params[:f_JT] = linkedin_job_type if criteria.job_type.present?
      end
      "#{base}?#{params.to_query}"
    end

    def extraction_script
      <<~JS
        Array.from(document.querySelectorAll('.base-card, .job-search-card, .base-search-card, [data-tracking-control-name="public_jobs_jserp-result"]')).slice(0, 25).map(card => {
          const titleEl = card.querySelector('.base-search-card__title, .job-search-card__title, h3');
          const companyEl = card.querySelector('.base-search-card__subtitle, .job-search-card__company-name, h4');
          const locationEl = card.querySelector('.job-search-card__location, .base-search-card__metadata');
          const linkEl = card.querySelector('a[href*="/jobs/"]') || card.querySelector('a');
          const timeEl = card.querySelector('time');

          return {
            title: titleEl ? titleEl.textContent.trim() : null,
            company: companyEl ? companyEl.textContent.trim() : null,
            location: locationEl ? locationEl.textContent.trim() : null,
            url: linkEl ? linkEl.href : null,
            posted_at: timeEl ? timeEl.getAttribute('datetime') : null
          };
        }).filter(item => item.title && item.title.length > 0)
      JS
    end

    def extract_listings(page_data)
      (page_data[:listings] || []).map do |raw|
        raw_sym = raw.is_a?(Hash) ? raw.symbolize_keys : {}
        normalize_listing(raw_sym.merge(source_platform: "linkedin"))
      end
    end

    private

    def linkedin_job_type
      case criteria&.job_type
      when "full_time" then "F"
      when "part_time" then "P"
      when "contract"  then "C"
      when "internship" then "I"
      else "F"
      end
    end
  end
end
