class JobListingsController < ApplicationController
  before_action :authenticate_user!
  layout "dashboard"

  before_action :set_listing, only: [:show, :update_status, :generate_cover_letter]

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

  def generate_cover_letter
    profile = current_user.profiles.first
    unless profile
      redirect_to job_listing_path(@listing), alert: "Please create a profile first."
      return
    end

    CoverLetterJob.perform_later(@listing.id, profile.id)
    redirect_to job_listing_path(@listing), notice: "Cover letter generation started. Refresh in a moment to see the result."
  end

  def bulk_update
    ids = params[:ids] || []
    new_status = params[:new_status]

    unless JobListing::STATUSES.include?(new_status)
      redirect_to job_listings_path, alert: "Invalid status."
      return
    end

    count = JobListing.for_user(current_user).where(id: ids).update_all(status: new_status)
    redirect_to job_listings_path, notice: "#{count} listings updated to #{new_status}."
  end

  private

  def set_listing
    @listing = JobListing.for_user(current_user).find(params[:id])
  end
end
