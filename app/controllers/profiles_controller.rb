class ProfilesController < ApplicationController
  before_action :authenticate_user!
  layout "dashboard"

  before_action :set_or_create_profile

  def show
  end

  def edit
  end

  def update
    if @profile.update(profile_params)
      redirect_to profile_path, notice: "Profile updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def upload_resume
    if params[:source_document].present?
      @profile.source_document.attach(params[:source_document])
      @profile.update!(source_mode: "upload")
      ResumeParseJob.perform_later(@profile.id)
      redirect_to edit_profile_path(anchor: "resume"), notice: "Resume uploaded. Text extraction in progress..."
    else
      redirect_to edit_profile_path(anchor: "resume"), alert: "Please select a file to upload."
    end
  end

  private

  def set_or_create_profile
    @profile = current_user.profiles.first_or_create!(title: "My Resume")
  end

  def profile_params
    params.require(:profile).permit(
      :title, :headline, :summary, :source_text, :status,
      contact_details: Profile::CONTACT_FIELDS,
      personal_details: [:date_of_birth, :nationality, :visa_status]
    )
  end
end
