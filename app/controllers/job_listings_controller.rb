class JobListingsController < ApplicationController
  before_action :authenticate_user!
  layout "dashboard"

  before_action :set_listing, only: [:show, :update_status]

  def index
    scope = JobListing.for_user(current_user)
                      .by_status(params[:status])
                      .recent
                      .includes(:job_source)

    scope = scope.where(job_source_id: params[:source_id]) if params[:source_id].present?
    @pagy, @listings = pagy(scope)
    @status_counts = JobListing.for_user(current_user).group(:status).count
  end

  def show
  end

  def update_status
    if JobListing::STATUSES.include?(params[:new_status])
      @listing.update!(status: params[:new_status])
      redirect_back fallback_location: job_listings_path, notice: "Status updated to #{params[:new_status]}."
    else
      redirect_back fallback_location: job_listings_path, alert: "Invalid status."
    end
  end

  private

  def set_listing
    @listing = JobListing.for_user(current_user).find(params[:id])
  end
end
