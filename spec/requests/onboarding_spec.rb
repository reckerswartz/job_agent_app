require "rails_helper"

RSpec.describe "Onboarding", type: :request do
  describe "GET /onboarding" do
    context "non-onboarded user" do
      let(:user) { create(:user, :not_onboarded) }
      before { sign_in user }

      it "renders the resume upload step first" do
        get onboarding_path
        expect(response).to have_http_status(:success)
        expect(response.body).to include("start with your resume")
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

    it "saves profile data and advances to source step" do
      post update_step_onboarding_path, params: {
        step: "profile",
        profile: { first_name: "John", surname: "Doe", email: "john@example.com", headline: "Developer" }
      }
      expect(response).to redirect_to(onboarding_path(step: "source"))

      profile = user.profiles.first
      expect(profile.contact_field("first_name")).to eq("John")
      expect(profile.headline).to eq("Developer")
    end

    it "saves job source and advances to complete" do
      post update_step_onboarding_path, params: {
        step: "source",
        job_source: { platform: "linkedin" }
      }
      expect(response).to redirect_to(onboarding_path(step: "complete"))
      expect(user.job_sources.count).to eq(1)
      expect(user.job_sources.first.name).to eq("My Linkedin")
    end

    it "saves source with optional criteria" do
      post update_step_onboarding_path, params: {
        step: "source",
        job_source: { platform: "indeed" },
        criteria: { keywords: "Ruby Developer", location: "NYC" }
      }
      expect(user.job_sources.count).to eq(1)
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

    it "advances from resume to profile" do
      post skip_step_onboarding_path, params: { step: "resume" }
      expect(response).to redirect_to(onboarding_path(step: "profile"))
    end

    it "advances from profile to source" do
      post skip_step_onboarding_path, params: { step: "profile" }
      expect(response).to redirect_to(onboarding_path(step: "source"))
    end
  end
end
