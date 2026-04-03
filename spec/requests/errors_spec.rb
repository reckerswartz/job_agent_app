require "rails_helper"

RSpec.describe "Error Handling", type: :request do
  describe "RecordNotFound rescue" do
    let(:user) { create(:user) }
    before { sign_in user }

    it "redirects to dashboard with flash for missing job listing" do
      get "/job_listings/999999"
      expect(response).to redirect_to(dashboard_path)
      follow_redirect!
      expect(response.body).to include("could not be found")
    end

    it "redirects to dashboard with flash for missing job application" do
      get "/job_applications/999999"
      expect(response).to redirect_to(dashboard_path)
    end

    it "redirects to dashboard with flash for missing intervention" do
      get "/interventions/999999"
      expect(response).to redirect_to(dashboard_path)
    end
  end

  describe "RecordNotFound for unauthenticated user" do
    it "redirects to sign in" do
      get "/job_listings/999999"
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
