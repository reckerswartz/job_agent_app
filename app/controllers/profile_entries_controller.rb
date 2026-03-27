class ProfileEntriesController < ApplicationController
  before_action :authenticate_user!
  layout "dashboard"

  before_action :set_profile
  before_action :set_section
  before_action :set_entry, only: [:update, :destroy]

  def create
    @entry = @section.profile_entries.build(entry_params)

    if @entry.save
      redirect_to edit_profile_path(anchor: @section.section_type), notice: "Entry added."
    else
      redirect_to edit_profile_path(anchor: @section.section_type), alert: @entry.errors.full_messages.join(", ")
    end
  end

  def update
    if @entry.update(entry_params)
      redirect_to edit_profile_path(anchor: @section.section_type), notice: "Entry updated."
    else
      redirect_to edit_profile_path(anchor: @section.section_type), alert: @entry.errors.full_messages.join(", ")
    end
  end

  def destroy
    @entry.destroy
    redirect_to edit_profile_path(anchor: @section.section_type), notice: "Entry removed."
  end

  private

  def set_profile
    @profile = current_user.profiles.first!
  end

  def set_section
    @section = @profile.profile_sections.find(params[:section_id])
  end

  def set_entry
    @entry = @section.profile_entries.find(params[:id])
  end

  def entry_params
    params.require(:profile_entry).permit(content: {})
  end
end
