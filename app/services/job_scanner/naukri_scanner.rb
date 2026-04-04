module JobScanner
  class NaukriScanner < Base
    NAUKRI_BASE = "https://www.naukri.com/".freeze

    def scan
      listings = try_browser_scan
      listings = try_http_scan if listings.empty?
      Rails.logger.info("[NaukriScanner] Total: #{listings.size} listings")
      listings
    end

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
          const jobId = card.getAttribute('data-job-id') || card.getAttribute('data-jobid');
          return {
            title: titleEl ? titleEl.textContent.trim() : null,
            company: companyEl ? companyEl.textContent.trim() : null,
            location: locationEl ? locationEl.textContent.trim() : null,
            url: linkEl ? linkEl.href : null,
            salary_range: salaryEl ? salaryEl.textContent.trim() : null,
            experience: expEl ? expEl.textContent.trim() : null,
            easy_apply: !!easyApplyEl,
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

    private

    def try_http_scan
      # Naukri is a JavaScript SPA — server-rendered HTML contains no job cards.
      # HTTP fallback cannot work for Naukri. A real browser (Playwright) is required.
      Rails.logger.warn("[NaukriScanner] HTTP fallback unavailable — Naukri requires a browser (JavaScript SPA)")
      []
    end

    def parse_naukri_cards(html)
      listings = []
      # Naukri renders job cards in article tags or divs with job data
      html.scan(/<article[^>]*class="[^"]*jobTuple[^"]*"[^>]*>(.*?)<\/article>/mi).each do |match|
        card = match[0]
        l = extract_naukri_card(card)
        listings << l if l[:title].present?
      end

      # Fallback: try srp-jobtuple-wrapper pattern
      if listings.empty?
        html.scan(/<div[^>]*class="[^"]*srp-jobtuple-wrapper[^"]*"[^>]*>(.*?)<\/div>\s*<\/div>\s*<\/div>/mi).each do |match|
          card = match[0]
          l = extract_naukri_card(card)
          listings << l if l[:title].present?
        end
      end

      # Fallback: try any element with data-job-id
      if listings.empty?
        html.scan(/data-job-id="(\d+)"/).each do |jid_match|
          jid = jid_match[0]
          # Extract surrounding context
          idx = html.index("data-job-id=\"#{jid}\"")
          next unless idx
          chunk = html[([idx - 2000, 0].max)..(idx + 3000)]
          l = extract_naukri_card(chunk)
          l[:external_id] = "naukri_#{jid}"
          listings << l if l[:title].present?
        end
      end

      listings.uniq { |l| l[:external_id] || l[:title] }.first(25)
    end

    def extract_naukri_card(card)
      title = card[/<a[^>]*class="[^"]*title[^"]*"[^>]*>([^<]+)/i, 1]&.strip ||
              card[/<a[^>]*title="([^"]+)"/i, 1]&.strip
      company = card[/class="[^"]*comp-name[^"]*"[^>]*>([^<]+)/i, 1]&.strip ||
                card[/class="[^"]*companyInfo[^"]*"[^>]*>.*?<a[^>]*>([^<]+)/mi, 1]&.strip
      location = card[/class="[^"]*loc(?:Wdth|ation|n)[^"]*"[^>]*>([^<]+)/i, 1]&.strip ||
                 card[/class="[^"]*locWdth[^"]*"[^>]*>([^<]+)/i, 1]&.strip
      url = card[/href="(https:\/\/www\.naukri\.com\/job-listings[^"]+)"/i, 1] ||
            card[/href="(\/job-listings[^"]+)"/i, 1]
      url = "https://www.naukri.com#{url}" if url&.start_with?("/")
      salary = card[/class="[^"]*sal[^"]*"[^>]*>([^<]+)/i, 1]&.strip
      jid = card[/data-job-id="(\d+)"/i, 1]
      ea = card.include?("easyApply") || card.include?("easy-apply")

      { title: title, company: company, location: location, url: url,
        salary_range: salary, easy_apply: ea, external_id: jid ? "naukri_#{jid}" : nil }
    end
  end
end
