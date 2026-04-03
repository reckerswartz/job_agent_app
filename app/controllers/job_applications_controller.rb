class JobApplicationsController < ApplicationController
  include DataTableable
  before_action :authenticate_user!
  layout "dashboard"

  before_action :set_application, only: [ :show, :retry_application ]

  def index
    scope = JobApplication.for_user(current_user)
                          .by_status(params[:status])
                          .includes(job_listing: :job_source)
    scope = apply_sorting(scope, %w[status created_at], default_column: "created_at")
    @pagy, @applications = pagy(scope, limit: per_page_limit)
    @status_counts = JobApplication.for_user(current_user).group(:status).count
  end

  def show
    @steps = @application.application_steps.order(step_number: :asc)
  end

  def create
    listing = JobListing.for_user(current_user).find(params[:job_listing_id])

    if listing.job_application.present?
      redirect_to job_listing_path(listing), alert: "This job already has an application."
      return
    end

    profile = current_user.profiles.first
    unless profile
      redirect_to job_listing_path(listing), alert: "Please create a profile first."
      return
    end

    application = JobApplication.create!(
      job_listing: listing,
      profile: profile,
      status: "queued"
    )

    JobApplyJob.perform_later(application.id)
    ActivityLogger.log(user: current_user, action: "application_created", category: "application",
      description: "Applied to #{listing.title} at #{listing.company}",
      trackable: application, metadata: { listing_title: listing.title, listing_company: listing.company })
    redirect_to job_application_path(application), notice: "Application queued. Processing will begin shortly."
  end

  def retry_application
    unless @application.can_retry?
      redirect_to job_application_path(@application), alert: "This application cannot be retried."
      return
    end

    @application.application_steps.destroy_all
    @application.update!(status: "queued", error_details: {})
    JobApplyJob.perform_later(@application.id)
    redirect_to job_application_path(@application), notice: "Application re-queued for retry."
  end

  private

  def set_application
    @application = JobApplication.for_user(current_user).find(params[:id])
  end
end
