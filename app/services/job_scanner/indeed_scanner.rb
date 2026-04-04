module JobScanner
  class IndeedScanner < Base
    INDEED_BASE = "https://www.indeed.com/jobs".freeze
    MAX_DETAIL_SCRAPES = 10

    def scan
      listings = try_browser_scan
      listings = try_http_scan if listings.empty?
      Rails.logger.info("[IndeedScanner] Total: #{listings.size} listings")
      listings
    end

    protected

    def build_search_url
      params = { fromage: 7, sort: "date" }
      if criteria
        params[:q] = criteria.keywords if criteria.keywords.present?
        params[:l] = criteria.location if criteria.location.present?
        params[:jt] = criteria.job_type if criteria.job_type.present?
        params[:remotejob] = "032b3046-06a3-4876-8dfd-474eb5e7ed11" if criteria.remote_preference == "remote"
      elsif job_source.user.profiles.first
        profile = job_source.user.profiles.first
        params[:q] = profile.headline if profile.headline.present?
        params[:l] = profile.contact_field("city") if profile.contact_field("city").present?
      end
      "#{INDEED_BASE}?#{params.to_query}"
    end

    def extraction_script
      <<~JS
        Array.from(document.querySelectorAll('.job_seen_beacon, .jobsearch-ResultsList > li, .result, [data-jk], .resultContent')).slice(0, 25).map(card => {
          const titleEl = card.querySelector('.jobTitle, .jcs-JobTitle, h2 a, h2 span, [data-testid="jobTitle"]');
          const companyEl = card.querySelector('.companyName, [data-testid="company-name"], .company');
          const locationEl = card.querySelector('.companyLocation, [data-testid="text-location"], .location');
          const linkEl = card.querySelector('a[href*="/viewjob"], a[href*="/rc/clk"], h2 a, .jobTitle a');
          const salaryEl = card.querySelector('.salary-snippet, .estimated-salary, [data-testid="attribute_snippet_testid"], .salary-snippet-container');
          const dateEl = card.querySelector('.date, .myJobsState, [data-testid="myJobsStateDate"]');
          const easyApplyEl = card.querySelector('.iaLabel, .indeedApply, [data-testid="indeedApply"]');
          const jk = card.getAttribute('data-jk') || card.closest('[data-jk]')?.getAttribute('data-jk');
          return {
            title: titleEl ? titleEl.textContent.trim() : null,
            company: companyEl ? companyEl.textContent.trim() : null,
            location: locationEl ? locationEl.textContent.trim() : null,
            url: linkEl ? (linkEl.href.startsWith('http') ? linkEl.href : 'https://www.indeed.com' + linkEl.getAttribute('href')) : null,
            salary_range: salaryEl ? salaryEl.textContent.trim() : null,
            posted_at: dateEl ? dateEl.textContent.trim() : null,
            easy_apply: !!easyApplyEl,
            external_id: jk ? ('indeed_' + jk) : null
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

    def has_next_page?(page_data)
      return false if (page_data[:listings] || []).size < 10
      @session.evaluate("!!document.querySelector('a[data-testid=\"pagination-page-next\"], .np, a[aria-label=\"Next Page\"]')") || false
    end

    def fetch_next_page(page_data)
      clicked = @session.evaluate(<<~JS)
        (() => {
          const next = document.querySelector('a[data-testid="pagination-page-next"], .np, a[aria-label="Next Page"]');
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
      Rails.logger.error("[IndeedScanner] fetch_next_page failed: #{e.message}")
      nil
    end

    private

    def try_http_scan
      url = build_search_url
      Rails.logger.info("[IndeedScanner] HTTP fallback: #{url}")
      html = fetch_html(url)
      return [] unless html

      listings = parse_indeed_cards(html)
      listings.map { |l| normalize_listing(l.merge(source_platform: "indeed")) }
    end

    def parse_indeed_cards(html)
      listings = []

      # Indeed renders job cards with data-jk attributes
      html.scan(/<a[^>]*data-jk="([^"]+)"[^>]*>/).each do |jk_match|
        jk = jk_match[0]
        idx = html.index("data-jk=\"#{jk}\"")
        next unless idx
        chunk = html[([ idx - 1000, 0 ].max)..(idx + 3000)]
        l = extract_indeed_card(chunk, jk)
        listings << l if l[:title].present?
      end

      # Fallback: look for jobTitle spans/links
      if listings.empty?
        html.scan(/<h2[^>]*class="[^"]*jobTitle[^"]*"[^>]*>(.*?)<\/h2>/mi).each do |match|
          title_html = match[0]
          title = title_html.gsub(/<[^>]+>/, "").strip
          next if title.blank?
          listings << { title: title, company: nil, location: nil, url: nil, external_id: nil }
        end
      end

      listings.uniq { |l| l[:external_id] || l[:title] }.first(25)
    end

    def extract_indeed_card(chunk, jk)
      title = chunk[/class="[^"]*jobTitle[^"]*"[^>]*>.*?<span[^>]*>([^<]+)/mi, 1]&.strip ||
              chunk[/title="([^"]+)"/i, 1]&.strip ||
              chunk[/<h2[^>]*>.*?<a[^>]*>.*?<span>([^<]+)/mi, 1]&.strip
      company = chunk[/class="[^"]*companyName[^"]*"[^>]*>([^<]+)/i, 1]&.strip ||
                chunk[/data-testid="company-name"[^>]*>([^<]+)/i, 1]&.strip
      location = chunk[/class="[^"]*companyLocation[^"]*"[^>]*>([^<]+)/i, 1]&.strip ||
                 chunk[/data-testid="text-location"[^>]*>([^<]+)/i, 1]&.strip
      salary = chunk[/class="[^"]*salary[^"]*"[^>]*>([^<]+)/i, 1]&.strip
      ea = chunk.include?("indeedApply") || chunk.include?("iaLabel")
      url = "https://www.indeed.com/viewjob?jk=#{jk}" if jk.present?

      { title: title, company: company, location: location, url: url,
        salary_range: salary, easy_apply: ea, external_id: jk ? "indeed_#{jk}" : nil }
    end
  end
end
