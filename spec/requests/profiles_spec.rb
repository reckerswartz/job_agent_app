require "rails_helper"

RSpec.describe "Profiles", type: :request do
  let(:user) { create(:user) }

  describe "authentication" do
    it "redirects to sign_in when not authenticated" do
      get profile_path
      expect(response).to redirect_to(sign_in_path)
    end
  end

  describe "GET /profile" do
    before { sign_in_as(user) }

    it "renders the profile show page" do
      get profile_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("My Profile")
    end

    it "auto-creates a profile if none exists" do
      expect { get profile_path }.to change(Profile, :count).by(1)
    end
  end

  describe "GET /profile/edit" do
    before { sign_in_as(user) }

    it "renders the profile edit form" do
      get edit_profile_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Edit Profile")
    end
  end

  describe "PATCH /profile" do
    before { sign_in_as(user) }

    it "updates contact details" do
      patch profile_path, params: {
        profile: {
          headline: "Senior Developer",
          contact_details: { first_name: "John", surname: "Doe", email: "john@example.com" }
        }
      }
      expect(response).to redirect_to(profile_path)

      profile = user.profiles.first
      expect(profile.headline).to eq("Senior Developer")
      expect(profile.contact_field("first_name")).to eq("John")
    end
  end

  describe "POST /profile/upload_resume" do
    before { sign_in_as(user) }

    it "uploads a PDF and enqueues parsing job" do
      post upload_resume_profile_path, params: {
        source_document: fixture_file_upload("sample_resume.pdf", "application/pdf")
      }

      expect(response).to redirect_to(edit_profile_path(anchor: "resume"))
      profile = user.profiles.first
      expect(profile.source_document).to be_attached
      expect(profile.source_mode).to eq("upload")
    end

    it "redirects with alert when no file provided" do
      post upload_resume_profile_path
      expect(response).to redirect_to(edit_profile_path(anchor: "resume"))
      expect(flash[:alert]).to be_present
    end
  end
end
