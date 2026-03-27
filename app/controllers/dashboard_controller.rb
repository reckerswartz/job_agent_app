class DashboardController < ApplicationController
  before_action :authenticate_user!
  layout "dashboard"

  def index
    @jobs_found = JobListing.for_user(current_user).count
    @high_matches = JobListing.for_user(current_user).high_match.count
    @applied = JobApplication.for_user(current_user).where(status: "submitted").count
    @pending_interventions = current_user.interventions.pending.count

    @recent_listings = JobListing.for_user(current_user).recent.limit(5).includes(:job_source)
    @recent_activity = DashboardActivityService.new(current_user).call
  end
end
