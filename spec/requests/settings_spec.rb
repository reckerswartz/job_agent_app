require "rails_helper"

RSpec.describe "Settings", type: :request do
  let(:user) { create(:user) }

  before { sign_in user }

  describe "GET /settings/edit" do
    it "renders the settings page" do
      get edit_settings_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Settings")
      expect(response.body).to include("Automations")
      expect(response.body).to include("Email Notifications")
    end
  end

  describe "PATCH /settings" do
    it "updates notification preferences" do
      patch settings_path, params: {
        notifications: { email_scan_completed: "true", email_new_matches: "false" }
      }
      expect(response).to redirect_to(edit_settings_path)
      follow_redirect!
      expect(response.body).to include("Settings saved successfully")

      user.reload
      expect(user.notification_settings["email_scan_completed"]).to be true
      expect(user.notification_settings["email_new_matches"]).to be false
    end

    it "updates auto-apply settings" do
      patch settings_path, params: {
        notifications: { auto_apply_enabled: "true", auto_apply_threshold: "85" }
      }
      expect(response).to redirect_to(edit_settings_path)

      user.reload
      expect(user.notification_settings["auto_apply_enabled"]).to be true
      expect(user.notification_settings["auto_apply_threshold"]).to be_truthy
    end

    it "redirects unauthenticated users" do
      sign_out user
      patch settings_path, params: { notifications: { email_scan_completed: "true" } }
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
