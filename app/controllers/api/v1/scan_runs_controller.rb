module Api
  module V1
    class ScanRunsController < Api::BaseController
      def index
        scope = JobScanRun.joins(:job_source).where(job_sources: { user_id: current_user.id })
                          .includes(:job_source).order(created_at: :desc)
        scope = scope.where(status: params[:status]) if params[:status].present?

        records, meta = paginate(scope)
        render_json(records.map { |r| serialize_run(r) }, meta: meta)
      end

      def show
        run = JobScanRun.joins(:job_source).where(job_sources: { user_id: current_user.id }).find(params[:id])
        render_json(serialize_run(run))
      end

      private

      def serialize_run(r)
        {
          id: r.id, status: r.status, source: r.job_source.name, platform: r.job_source.platform,
          listings_found: r.listings_found, new_listings: r.new_listings,
          duration_ms: r.duration_ms, started_at: r.started_at, finished_at: r.finished_at,
          error: r.failed? ? r.error_details["message"] : nil
        }
      end
    end
  end
end
