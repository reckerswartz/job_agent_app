module JobScanner
  class GenericScanner < Base
    protected

    def extract_listings(page_data)
      (page_data[:listings] || []).map do |raw|
        normalize_listing(raw.merge(source_platform: job_source.platform))
      end
    end
  end
end
