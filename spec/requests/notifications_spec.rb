require "rails_helper"

RSpec.describe "Notifications", type: :request do
  let(:user) { create(:user) }

  before { sign_in user }

  describe "GET /notifications" do
    it "renders the notifications page" do
      create_list(:notification, 3, user: user)
      get notifications_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Notifications")
    end

    it "marks unread notifications as read on visit" do
      notif = create(:notification, user: user, read_at: nil)
      get notifications_path
      expect(notif.reload.read_at).not_to be_nil
    end

    it "shows empty state when no notifications" do
      get notifications_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("No notifications yet")
    end
  end

  describe "PATCH /notifications/:id/mark_read" do
    it "marks a notification as read" do
      notif = create(:notification, user: user, read_at: nil)
      patch mark_read_notification_path(notif)
      expect(notif.reload.read_at).not_to be_nil
    end

    it "does not allow marking another user's notification" do
      other_user = create(:user)
      notif = create(:notification, user: other_user)
      patch mark_read_notification_path(notif)
      # RecordNotFound is rescued by ApplicationController and redirects to dashboard
      expect(response).to redirect_to(dashboard_path)
    end
  end

  describe "PATCH /notifications/mark_all_read" do
    it "marks all unread notifications as read" do
      create_list(:notification, 3, user: user, read_at: nil)
      expect(user.notifications.unread.count).to eq(3)

      patch mark_all_read_notifications_path
      expect(user.notifications.unread.count).to eq(0)
      expect(response).to redirect_to(notifications_path)
    end
  end

  context "when not authenticated" do
    before { sign_out user }

    it "redirects to sign in" do
      get notifications_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
