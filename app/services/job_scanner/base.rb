module JobScanner
  class Base
    MAX_PAGES = 3

    def initialize(job_source, criteria = nil)
      @job_source = job_source
      @criteria = criteria
    end

    def scan
      listings = []
      search_url = build_search_url

      page_data = fetch_page(search_url)
      return listings if page_data.nil?

      MAX_PAGES.times do |page_num|
        page_listings = extract_listings(page_data)
        listings.concat(page_listings)

        break unless has_next_page?(page_data)
        break if page_num >= MAX_PAGES - 1

        page_data = fetch_next_page(page_data)
        break if page_data.nil?
      end

      listings
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
      { url: url, html: "", listings: [] }
    end

    def extract_listings(page_data)
      []
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
        raw_data: raw
      }
    end

    private

    def parse_date(value)
      return nil if value.blank?
      return value if value.is_a?(Time) || value.is_a?(DateTime)

      Time.zone.parse(value.to_s) rescue nil
    end
  end
end
