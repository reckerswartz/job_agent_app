module JobScanner
  class Base
    MAX_PAGES = 3

    def initialize(job_source, criteria = nil)
      @job_source = job_source
      @criteria = criteria
      @session = nil
    end

    def scan
      listings = try_browser_scan
      Rails.logger.info("[#{self.class.name}] Total: #{listings.size} listings")
      listings
    end

    def try_browser_scan
      listings = []
      search_url = build_search_url

      @session = Timeout.timeout(10) { BrowserSession.new }
      page_data = fetch_page(search_url)
      return listings if page_data.nil?

      if @session.login_required?
        create_login_intervention!
        return listings
      end

      if @session.captcha_detected?
        create_captcha_intervention!
        return listings
      end

      MAX_PAGES.times do |page_num|
        page_listings = extract_listings(page_data)
        listings.concat(page_listings)

        break unless has_next_page?(page_data)
        break if page_num >= MAX_PAGES - 1

        page_data = fetch_next_page(page_data)
        break if page_data.nil?
      end

      listings
    rescue Errno::ENOENT, IOError, RuntimeError, Timeout::Error => e
      Rails.logger.warn("[#{self.class.name}] Browser unavailable: #{e.message}")
      []
    ensure
      @session&.close
    end

    protected

    attr_reader :job_source, :criteria

    def build_search_url
      base = job_source.base_url.to_s
      params = {}
      if criteria
        params[:q] = criteria.keywords if criteria.keywords.present?
        params[:l] = criteria.location if criteria.location.present?
      end
      params.any? ? "#{base}?#{params.to_query}" : base
    end

    def fetch_page(url)
      html = @session.navigate(url)
      return nil if html.nil?

      raw_listings = @session.evaluate(extraction_script) || []
      { url: url, html: html, listings: raw_listings }
    rescue => e
      Rails.logger.error("[JobScanner] fetch_page failed: #{e.message}")
      nil
    end

    def extraction_script
      "[]"
    end

    def extract_listings(page_data)
      (page_data[:listings] || []).map do |raw|
        raw_sym = raw.is_a?(Hash) ? raw.symbolize_keys : {}
        normalize_listing(raw_sym)
      end
    end

    def has_next_page?(page_data)
      false
    end

    def fetch_next_page(page_data)
      nil
    end

    def generate_external_id(listing_hash)
      content = "#{listing_hash[:title]}|#{listing_hash[:company]}|#{listing_hash[:url]}"
      Digest::SHA256.hexdigest(content)[0..15]
    end

    def normalize_listing(raw)
      {
        external_id: raw[:external_id] || generate_external_id(raw),
        title: raw[:title].to_s.strip,
        company: raw[:company].to_s.strip,
        location: raw[:location].to_s.strip,
        salary_range: raw[:salary_range].to_s.strip.presence,
        description: raw[:description].to_s.strip.presence,
        requirements: raw[:requirements].to_s.strip.presence,
        url: raw[:url].to_s.strip,
        posted_at: parse_date(raw[:posted_at]),
        employment_type: raw[:employment_type].to_s.strip.presence,
        remote_type: raw[:remote_type].to_s.strip.presence,
        easy_apply: raw[:easy_apply] || false,
        resume_upload_supported: raw[:resume_upload_supported] || false,
        application_url: raw[:application_url].to_s.strip.presence,
        raw_data: raw
      }
    end

    def fetch_html(url)
      uri = URI(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"
      http.read_timeout = 30
      http.open_timeout = 15

      req = Net::HTTP::Get.new(uri)
      req["User-Agent"] = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
      req["Accept"] = "text/html,application/xhtml+xml"
      req["Accept-Language"] = "en-US,en;q=0.5"

      resp = http.request(req)
      Rails.logger.info("[#{self.class.name}] HTTP #{resp.code} for #{uri.host}")
      resp.code.to_i == 200 ? resp.body : nil
    rescue => e
      Rails.logger.error("[#{self.class.name}] HTTP failed: #{e.message}")
      nil
    end

    private

    def parse_date(value)
      return nil if value.blank?
      return value if value.is_a?(Time) || value.is_a?(DateTime)

      Time.zone.parse(value.to_s) rescue nil
    end

    def create_login_intervention!
      InterventionCreator.create_for(
        job_source,
        type: "login_required",
        context: { page_url: @session.current_url, source: job_source.name },
        user: job_source.user
      )
      job_source.update!(status: "needs_login")
    end

    def create_captcha_intervention!
      InterventionCreator.create_for(
        job_source,
        type: "captcha",
        context: { page_url: @session.current_url, source: job_source.name },
        user: job_source.user
      )
    end
  end
end
