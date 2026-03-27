require "rails_helper"

RSpec.describe "ProfileSections", type: :request do
  let(:user) { create(:user) }
  let!(:profile) { create(:profile, user: user) }

  before { sign_in user }

  describe "POST /profile/sections" do
    it "creates a new section" do
      expect {
        post profile_sections_path, params: {
          profile_section: { section_type: "work_experience", title: "Work Experience" }
        }
      }.to change(ProfileSection, :count).by(1)

      expect(response).to redirect_to(edit_profile_path(anchor: "work_experience"))
    end

    it "rejects invalid section types" do
      post profile_sections_path, params: {
        profile_section: { section_type: "invalid_type", title: "Bad" }
      }
      expect(response).to redirect_to(edit_profile_path)
      expect(flash[:alert]).to be_present
    end
  end

  describe "DELETE /profile/sections/:id" do
    it "destroys the section" do
      section = create(:profile_section, profile: profile)
      expect {
        delete profile_section_path(section)
      }.to change(ProfileSection, :count).by(-1)

      expect(response).to redirect_to(edit_profile_path)
    end
  end
end
