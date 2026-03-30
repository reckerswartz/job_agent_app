require "rails_helper"

RSpec.describe "Onboarding", type: :request do
  describe "GET /onboarding" do
    context "non-onboarded user" do
      let(:user) { create(:user, :not_onboarded) }
      before { sign_in user }

      it "renders the onboarding wizard" do
        get onboarding_path
        expect(response).to have_http_status(:success)
        expect(response.body).to include("Welcome to Job Agent")
      end
    end

    context "onboarded user" do
      let(:user) { create(:user) }
      before { sign_in user }

      it "still allows access to onboarding page" do
        get onboarding_path
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "onboarding redirect" do
    context "non-onboarded user visiting dashboard" do
      let(:user) { create(:user, :not_onboarded) }
      before { sign_in user }

      it "redirects to onboarding" do
        get dashboard_path
        expect(response).to redirect_to(onboarding_path)
      end
    end

    context "onboarded user visiting dashboard" do
      let(:user) { create(:user) }
      before { sign_in user }

      it "does not redirect" do
        get dashboard_path
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "POST /onboarding/update_step" do
    let(:user) { create(:user, :not_onboarded) }
    before { sign_in user }

    it "saves profile data and advances to next step" do
      post update_step_onboarding_path, params: {
        step: "profile",
        profile: { first_name: "John", surname: "Doe", email: "john@example.com", headline: "Developer" }
      }
      expect(response).to redirect_to(onboarding_path(step: "resume"))

      profile = user.profiles.first
      expect(profile.contact_field("first_name")).to eq("John")
      expect(profile.headline).to eq("Developer")
    end

    it "saves job source and advances" do
      post update_step_onboarding_path, params: {
        step: "source",
        job_source: { platform: "linkedin", name: "My LinkedIn" }
      }
      expect(response).to redirect_to(onboarding_path(step: "criteria"))
      expect(user.job_sources.count).to eq(1)
    end

    it "saves search criteria and advances" do
      post update_step_onboarding_path, params: {
        step: "criteria",
        criteria: { keywords: "Ruby Developer", location: "NYC", remote_preference: "remote" }
      }
      expect(response).to redirect_to(onboarding_path(step: "complete"))
      expect(user.job_search_criteria.count).to eq(1)
    end

    it "marks onboarding complete and redirects to dashboard" do
      post update_step_onboarding_path, params: { step: "complete" }
      expect(user.reload.onboarding_completed?).to be true
      expect(response).to redirect_to(dashboard_path)
    end
  end

  describe "POST /onboarding/skip_step" do
    let(:user) { create(:user, :not_onboarded) }
    before { sign_in user }

    it "advances to next step without saving" do
      post skip_step_onboarding_path, params: { step: "profile" }
      expect(response).to redirect_to(onboarding_path(step: "resume"))
    end
  end
end
