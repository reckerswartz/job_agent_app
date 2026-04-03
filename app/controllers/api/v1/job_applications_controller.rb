module Api
  module V1
    class JobApplicationsController < Api::BaseController
      def index
        scope = JobApplication.for_user(current_user).includes(job_listing: :job_source)
        scope = scope.by_status(params[:status]) if params[:status].present?
        scope = scope.order(created_at: :desc)

        records, meta = paginate(scope)
        render_json(records.map { |a| serialize_application(a) }, meta: meta)
      end

      def show
        app = JobApplication.for_user(current_user).find(params[:id])
        render_json(serialize_application(app, include_steps: true))
      end

      def create
        listing = JobListing.for_user(current_user).find(params[:job_listing_id])

        if listing.job_application.present?
          return render json: { error: "This job already has an application." }, status: :unprocessable_entity
        end

        profile = current_user.profiles.first
        return render json: { error: "Please create a profile first." }, status: :unprocessable_entity unless profile

        application = JobApplication.create!(job_listing: listing, profile: profile, status: "queued")
        JobApplyJob.perform_later(application.id)
        render_json(serialize_application(application), status: :created)
      end

      private

      def serialize_application(a, include_steps: false)
        data = {
          id: a.id, status: a.status, applied_at: a.applied_at,
          listing: { id: a.job_listing.id, title: a.job_listing.title, company: a.job_listing.company },
          created_at: a.created_at
        }
        if include_steps
          data[:steps] = a.application_steps.order(:step_number).map { |s|
            { step: s.step_number, action: s.action, status: s.status }
          }
        end
        data
      end
    end
  end
end
