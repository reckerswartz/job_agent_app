require "rails_helper"

RSpec.describe NotificationCreator do
  let(:user) { create(:user) }

  describe ".create" do
    it "creates a notification for the user" do
      notif = described_class.create(
        user: user, title: "Test", body: "Body", category: "system", action_url: "/dashboard"
      )
      expect(notif).to be_a(Notification)
      expect(notif).to be_persisted
      expect(notif.title).to eq("Test")
      expect(notif.user).to eq(user)
    end

    it "returns nil and logs on failure" do
      allow(user).to receive_message_chain(:notifications, :create!).and_raise(ActiveRecord::RecordInvalid)
      result = described_class.create(user: user, title: nil)
      expect(result).to be_nil
    end

    it "allows optional fields to be nil" do
      notif = described_class.create(user: user, title: "Minimal")
      expect(notif).to be_persisted
      expect(notif.body).to be_nil
      expect(notif.category).to be_nil
    end
  end
end
