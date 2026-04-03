module Api
  module V1
    class JobSourcesController < Api::BaseController
      def index
        sources = current_user.job_sources.order(:name)
        render_json(sources.map { |s| serialize_source(s) })
      end

      def show
        source = current_user.job_sources.find(params[:id])
        render_json(serialize_source(source))
      end

      def scan
        source = current_user.job_sources.find(params[:id])
        run = source.job_scan_runs.create!(status: "running", started_at: Time.current)
        JobScanJob.perform_later(source.id)
        render_json({ scan_run_id: run.id, status: "queued", message: "Scan started." }, status: :accepted)
      end

      private

      def serialize_source(s)
        {
          id: s.id, name: s.name, platform: s.platform, enabled: s.enabled,
          last_scanned_at: s.last_scanned_at, scan_interval_hours: s.scan_interval_hours,
          listings_count: s.job_listings.count
        }
      end
    end
  end
end
