module Api
  module V1
    class JobListingsController < Api::BaseController
      def index
        scope = JobListing.for_user(current_user).includes(:job_source)
        scope = scope.by_status(params[:status]) if params[:status].present?
        scope = scope.search(params[:q]) if params[:q].present?
        scope = scope.order(created_at: :desc)

        records, meta = paginate(scope)
        render_json(records.map { |l| serialize_listing(l) }, meta: meta)
      end

      def show
        listing = JobListing.for_user(current_user).find(params[:id])
        render_json(serialize_listing(listing))
      end

      private

      def serialize_listing(l)
        {
          id: l.id, title: l.title, company: l.company, location: l.location,
          url: l.url, status: l.status, match_score: l.match_score,
          easy_apply: l.easy_apply, salary_range: l.salary_range,
          employment_type: l.employment_type, remote_type: l.remote_type,
          source: l.job_source.platform, posted_at: l.posted_at, created_at: l.created_at
        }
      end
    end
  end
end
