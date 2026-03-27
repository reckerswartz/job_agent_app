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

    def extract_listings(page_data)
      (page_data[:listings] || []).map do |raw|
        normalize_listing(raw.merge(source_platform: "linkedin"))
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
