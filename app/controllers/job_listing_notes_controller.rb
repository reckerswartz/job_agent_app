class JobListingNotesController < ApplicationController
  before_action :authenticate_user!
  layout "dashboard"

  before_action :set_listing

  def create
    @note = @listing.job_listing_notes.build(note_params)
    @note.user = current_user

    if @note.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to job_listing_path(@listing), notice: "Note added." }
      end
    else
      redirect_to job_listing_path(@listing), alert: "Failed to add note: #{@note.errors.full_messages.join(', ')}"
    end
  end

  def destroy
    @note = @listing.job_listing_notes.where(user: current_user).find(params[:id])
    @note.destroy

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to job_listing_path(@listing), notice: "Note removed." }
    end
  end

  private

  def set_listing
    @listing = JobListing.for_user(current_user).find(params[:job_listing_id])
  end

  def note_params
    params.require(:job_listing_note).permit(:content)
  end
end
