module Admin
  class ScanRunsController < BaseController
    include DataTableable

    def index
      scope = JobScanRun.includes(:job_source)
      scope = scope.where(status: params[:status]) if params[:status].present?
      scope = apply_sorting(scope, %w[id status started_at listings_found new_listings], default_column: "id")
      @pagy, @scan_runs = pagy(scope, limit: per_page_limit)
    end

    def show
      @scan_run = JobScanRun.find(params[:id])
    end
  end
end
