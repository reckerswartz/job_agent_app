require "rails_helper"

RSpec.describe "ProfileEntries", type: :request do
  let(:user) { create(:user) }
  let!(:profile) { create(:profile, user: user) }
  let!(:section) { create(:profile_section, profile: profile, section_type: "work_experience") }

  before { sign_in_as(user) }

  describe "POST /profile/sections/:section_id/entries" do
    it "creates a new entry" do
      expect {
        post profile_section_entries_path(section), params: {
          profile_entry: { content: { title: "Developer", company: "Acme" } }
        }
      }.to change(ProfileEntry, :count).by(1)

      expect(response).to redirect_to(edit_profile_path(anchor: "work_experience"))
    end
  end

  describe "PATCH /profile/sections/:section_id/entries/:id" do
    let!(:entry) { create(:profile_entry, profile_section: section) }

    it "updates the entry content" do
      patch profile_section_entry_path(section, entry), params: {
        profile_entry: { content: { title: "Senior Developer", company: "BigCorp" } }
      }
      expect(response).to redirect_to(edit_profile_path(anchor: "work_experience"))
      expect(entry.reload.content["title"]).to eq("Senior Developer")
    end
  end

  describe "DELETE /profile/sections/:section_id/entries/:id" do
    let!(:entry) { create(:profile_entry, profile_section: section) }

    it "destroys the entry" do
      expect {
        delete profile_section_entry_path(section, entry)
      }.to change(ProfileEntry, :count).by(-1)

      expect(response).to redirect_to(edit_profile_path(anchor: "work_experience"))
    end
  end
end
