module Admin
  class ScanRunsController < BaseController
    def index
      @pagy, @scan_runs = pagy(
        JobScanRun.recent.includes(:job_source),
        limit: 25
      )
    end

    def show
      @scan_run = JobScanRun.find(params[:id])
    end
  end
end
