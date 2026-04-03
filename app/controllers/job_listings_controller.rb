class JobListingsController < ApplicationController
  include DataTableable
  before_action :authenticate_user!
  layout "dashboard"

  before_action :set_listing, only: [ :show, :update_status, :generate_cover_letter, :analyze_match, :tailor_resume, :download_cover_letter, :download_resume ]

  def index
    scope = JobListing.for_user(current_user)
                      .search(params[:q])
                      .by_status(params[:status])
                      .includes(:job_source)

    scope = scope.where(job_source_id: params[:source_id]) if params[:source_id].present?
    scope = apply_sorting(scope, %w[title company match_score posted_at created_at], default_column: "created_at")
    @pagy, @listings = pagy(scope, limit: per_page_limit)
    @status_counts = JobListing.for_user(current_user).group(:status).count
    @search_query = params[:q]
  end

  def show
  end

  def update_status
    if JobListing::STATUSES.include?(params[:new_status])
      old_status = @listing.status
      @listing.update!(status: params[:new_status])
      ActivityLogger.log(user: current_user, action: "listing_status_changed", category: "listing",
        description: "Changed #{@listing.title} from #{old_status} to #{params[:new_status]}",
        trackable: @listing, metadata: { old_status: old_status, new_status: params[:new_status] })
      redirect_back fallback_location: job_listings_path, notice: "Status updated to #{params[:new_status]}."
    else
      redirect_back fallback_location: job_listings_path, alert: "Invalid status."
    end
  end

  def analyze_match
    profile = current_user.profiles.first
    unless profile
      redirect_to job_listing_path(@listing), alert: "Please create a profile first."
      return
    end

    analysis = Llm::Pipeline::JobMatch.new(@listing, profile).analyze
    if analysis
      redirect_to job_listing_path(@listing), notice: "AI match analysis complete."
    else
      redirect_to job_listing_path(@listing), alert: "AI analysis unavailable. Check LLM configuration."
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

  def tailor_resume
    profile = current_user.profiles.first
    unless profile
      redirect_to job_listing_path(@listing), alert: "Please create a profile first."
      return
    end

    result = ResumeTailorService.new(@listing, profile).tailor
    if result
      redirect_to job_listing_path(@listing), notice: "Resume tailored for this job."
    else
      redirect_to job_listing_path(@listing), alert: "Resume tailoring unavailable. Check LLM configuration."
    end
  end

  def download_cover_letter
    cover_letter = @listing.cover_letters.recent.first
    cover_letter ||= CoverLetter.new(job_listing: @listing, profile: current_user.profiles.first,
                                      content: @listing.metadata&.dig("cover_letter") || "No cover letter generated yet.")

    pdf_data = Pdf::CoverLetterPdf.new(cover_letter).render
    send_data pdf_data, filename: "cover_letter_#{@listing.company&.parameterize}_#{Date.current}.pdf",
              type: "application/pdf", disposition: "inline"
  end

  def download_resume
    profile = current_user.profiles.first
    unless profile
      redirect_to job_listing_path(@listing), alert: "Please create a profile first."
      return
    end

    tailored_data = @listing.match_breakdown&.dig("tailored_resume")
    pdf_data = Pdf::ResumePdf.new(profile, tailored_data).render
    send_data pdf_data, filename: "resume_#{profile.display_name.parameterize}_#{Date.current}.pdf",
              type: "application/pdf", disposition: "inline"
  end

  def export
    listings = JobListing.for_user(current_user).by_status(params[:status]).recent
    csv_data = generate_csv(listings)
    send_data csv_data, filename: "job_listings_#{Date.current}.csv", type: "text/csv"
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

  def generate_csv(listings)
    require "csv"
    CSV.generate(headers: true) do |csv|
      csv << %w[Title Company Location Match_Score Status Source URL Posted_At]
      listings.includes(:job_source).find_each do |listing|
        csv << [
          listing.title,
          listing.company,
          listing.location,
          listing.match_score,
          listing.status,
          listing.job_source.platform,
          listing.url,
          listing.posted_at&.iso8601
        ]
      end
    end
  end
end
