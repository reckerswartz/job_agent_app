class DashboardController < ApplicationController
  before_action :authenticate_user!
  layout "dashboard"

  def index
    @jobs_found = JobListing.for_user(current_user).count
    @high_matches = JobListing.for_user(current_user).high_match.count
    @applied = JobApplication.for_user(current_user).where(status: "submitted").count
    @pending_interventions = current_user.interventions.pending.count

    @recent_listings = JobListing.for_user(current_user).not_duplicate.recent.limit(5).includes(:job_source)
    @recommended_listings = JobListing.for_user(current_user).not_duplicate.recommended.limit(5).includes(:job_source)
    @upcoming_interviews = Interview.for_user(current_user).upcoming.limit(5).includes(job_application: { job_listing: :job_source })
    @recent_activity = DashboardActivityService.new(current_user).call
  end
end
