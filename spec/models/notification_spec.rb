require "rails_helper"

RSpec.describe Notification, type: :model do
  let(:user) { create(:user) }
  let(:notification) { build(:notification, user: user) }

  describe "validations" do
    it "is valid with valid attributes" do
      expect(notification).to be_valid
    end

    it "requires title" do
      notification.title = nil
      expect(notification).not_to be_valid
    end

    it "allows nil category" do
      notification.category = nil
      expect(notification).to be_valid
    end

    it "rejects invalid category" do
      notification.category = "invalid"
      expect(notification).not_to be_valid
    end

    it "accepts valid categories" do
      Notification::CATEGORIES.each do |cat|
        notification.category = cat
        expect(notification).to be_valid
      end
    end
  end

  describe "#read?" do
    it "returns false when read_at is nil" do
      expect(notification.read?).to be false
    end

    it "returns true when read_at is set" do
      notification.read_at = Time.current
      expect(notification.read?).to be true
    end
  end

  describe "#mark_read!" do
    it "sets read_at timestamp" do
      notification.save!
      notification.mark_read!
      expect(notification.reload.read_at).not_to be_nil
    end

    it "is idempotent — does not update if already read" do
      notification.save!
      notification.mark_read!
      first_read = notification.reload.read_at
      notification.mark_read!
      expect(notification.reload.read_at).to eq(first_read)
    end
  end

  describe "scopes" do
    before do
      create(:notification, user: user, read_at: nil)
      create(:notification, :read, user: user)
    end

    it ".unread returns only unread notifications" do
      expect(user.notifications.unread.count).to eq(1)
    end

    it ".recent orders by created_at desc" do
      old = create(:notification, user: user, created_at: 2.days.ago, read_at: nil)
      recent = create(:notification, user: user, created_at: 1.second.ago, read_at: nil)
      results = user.notifications.recent.to_a
      expect(results.index(recent)).to be < results.index(old)
    end
  end
end
