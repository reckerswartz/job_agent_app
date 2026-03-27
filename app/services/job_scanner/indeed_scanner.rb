module JobScanner
  class IndeedScanner < Base
    protected

    def build_search_url
      base = "https://www.indeed.com/jobs"
      params = { fromage: 7 }
      if criteria
        params[:q] = criteria.keywords if criteria.keywords.present?
        params[:l] = criteria.location if criteria.location.present?
        params[:jt] = criteria.job_type if criteria.job_type.present?
      end
      "#{base}?#{params.to_query}"
    end

    def extraction_script
      <<~JS
        Array.from(document.querySelectorAll('.job_seen_beacon, .jobsearch-ResultsList > li, .result, [data-jk]')).slice(0, 25).map(card => {
          const titleEl = card.querySelector('.jobTitle, .jcs-JobTitle, h2 a, h2 span');
          const companyEl = card.querySelector('.companyName, [data-testid="company-name"], .company');
          const locationEl = card.querySelector('.companyLocation, [data-testid="text-location"], .location');
          const linkEl = card.querySelector('a[href*="/viewjob"], a[href*="/rc/clk"], h2 a');
          const salaryEl = card.querySelector('.salary-snippet, .estimated-salary, [data-testid="attribute_snippet_testid"]');
          const dateEl = card.querySelector('.date, .myJobsState');

          return {
            title: titleEl ? titleEl.textContent.trim() : null,
            company: companyEl ? companyEl.textContent.trim() : null,
            location: locationEl ? locationEl.textContent.trim() : null,
            url: linkEl ? (linkEl.href.startsWith('http') ? linkEl.href : 'https://www.indeed.com' + linkEl.getAttribute('href')) : null,
            salary_range: salaryEl ? salaryEl.textContent.trim() : null,
            posted_at: dateEl ? dateEl.textContent.trim() : null
          };
        }).filter(item => item.title && item.title.length > 0)
      JS
    end

    def extract_listings(page_data)
      (page_data[:listings] || []).map do |raw|
        raw_sym = raw.is_a?(Hash) ? raw.symbolize_keys : {}
        normalize_listing(raw_sym.merge(source_platform: "indeed"))
      end
    end
  end
end
