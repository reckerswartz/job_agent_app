class ProfileSectionsController < ApplicationController
  before_action :authenticate_user!
  layout "dashboard"

  before_action :set_profile
  before_action :set_section, only: [ :destroy ]

  def create
    @section = @profile.profile_sections.build(section_params)

    if @section.save
      redirect_to edit_profile_path(anchor: @section.section_type), notice: "#{@section.title} section added."
    else
      redirect_to edit_profile_path, alert: @section.errors.full_messages.join(", ")
    end
  end

  def destroy
    title = @section.title
    @section.destroy
    redirect_to edit_profile_path, notice: "#{title} section removed."
  end

  private

  def set_profile
    @profile = current_user.profiles.first!
  end

  def set_section
    @section = @profile.profile_sections.find(params[:id])
  end

  def section_params
    params.require(:profile_section).permit(:section_type, :title)
  end
end
