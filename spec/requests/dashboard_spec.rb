require "rails_helper"

RSpec.describe "Dashboard", type: :request do
  let(:user) { create(:user) }

  before { sign_in user }

  describe "GET /dashboard" do
    it "renders the dashboard page" do
      get dashboard_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Dashboard")
    end

    it "shows stat cards" do
      get dashboard_path
      expect(response.body).to include("Jobs Found")
      expect(response.body).to include("High Matches")
      expect(response.body).to include("Applied")
      expect(response.body).to include("Needs Attention")
    end

    it "shows recent job listings section" do
      get dashboard_path
      expect(response.body).to include("Recent Job Listings")
    end

    it "shows recent activity section" do
      get dashboard_path
      expect(response.body).to include("Recent Activity")
    end

    it "redirects unauthenticated users to sign in" do
      sign_out user
      get dashboard_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
