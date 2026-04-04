require "rails_helper"

RSpec.describe "ActivityLogs", type: :request do
  let(:user) { create(:user) }

  before { sign_in user }

  describe "GET /activity" do
    it "renders the activity page" do
      get activity_logs_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Activity")
    end

    it "shows activity log entries" do
      user.activity_logs.create!(action: "scan_completed", category: "scan", description: "Test scan completed")
      get activity_logs_path
      expect(response.body).to include("Test scan completed")
    end

    it "filters by category" do
      user.activity_logs.create!(action: "scan_completed", category: "scan", description: "Scan entry")
      user.activity_logs.create!(action: "profile_updated", category: "profile", description: "Profile entry")
      get activity_logs_path(category: "scan")
      expect(response.body).to include("Scan entry")
      expect(response.body).not_to include("Profile entry")
    end

    it "shows empty state when no activity" do
      get activity_logs_path
      expect(response.body).to include("No activity yet")
    end

    it "redirects unauthenticated users" do
      sign_out user
      get activity_logs_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
