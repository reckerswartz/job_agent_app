module JobScanner
  class NaukriScanner < Base
    protected

    def build_search_url
      base = "https://www.naukri.com/"
      if criteria&.keywords.present?
        slug = criteria.keywords.downcase.gsub(/\s+/, "-")
        "#{base}#{slug}-jobs"
      else
        base
      end
    end

    def extraction_script
      <<~JS
        Array.from(document.querySelectorAll('.srp-jobtuple-wrapper, .jobTuple, article.jobTuple')).slice(0, 25).map(card => {
          const titleEl = card.querySelector('.title, a.title, .row1 a');
          const companyEl = card.querySelector('.comp-name, .companyInfo a, .row2 .comp-name');
          const locationEl = card.querySelector('.loc-wrap .locWdth, .location, .row4 .loc');
          const linkEl = card.querySelector('a.title, a[href*="/job-listings"]') || card.querySelector('a');
          const salaryEl = card.querySelector('.sal-wrap .ni-job-tuple-icon-srp-rupee, .salary');
          const expEl = card.querySelector('.exp-wrap .expwdth, .experience');

          return {
            title: titleEl ? titleEl.textContent.trim() : null,
            company: companyEl ? companyEl.textContent.trim() : null,
            location: locationEl ? locationEl.textContent.trim() : null,
            url: linkEl ? linkEl.href : null,
            salary_range: salaryEl ? salaryEl.textContent.trim() : null,
            experience: expEl ? expEl.textContent.trim() : null
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
  end
end
