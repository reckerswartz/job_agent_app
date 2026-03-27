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

    def extract_listings(page_data)
      (page_data[:listings] || []).map do |raw|
        normalize_listing(raw.merge(source_platform: "indeed"))
      end
    end
  end
end
