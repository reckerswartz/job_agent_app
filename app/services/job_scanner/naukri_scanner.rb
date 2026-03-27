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

    def extract_listings(page_data)
      (page_data[:listings] || []).map do |raw|
        normalize_listing(raw.merge(source_platform: "naukri"))
      end
    end
  end
end
