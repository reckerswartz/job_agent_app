require "rails_helper"

RSpec.describe ActivityLog, type: :model do
  let(:user) { create(:user) }

  it "validates action presence" do
    log = ActivityLog.new(user: user, action: nil)
    expect(log).not_to be_valid
    expect(log.errors[:action]).to include("can't be blank")
  end

  it "validates category inclusion" do
    log = ActivityLog.new(user: user, action: "test", category: "invalid")
    expect(log).not_to be_valid
  end

  it "allows nil category" do
    log = ActivityLog.new(user: user, action: "test", category: nil)
    expect(log).to be_valid
  end

  it "creates a valid activity log" do
    log = ActivityLog.create!(user: user, action: "test_action", category: "scan", description: "Test")
    expect(log).to be_persisted
    expect(log.action).to eq("test_action")
  end

  describe "scopes" do
    it ".recent orders by created_at desc" do
      old = ActivityLog.create!(user: user, action: "old", created_at: 1.day.ago)
      recent = ActivityLog.create!(user: user, action: "new")
      expect(ActivityLog.recent.first).to eq(recent)
    end

    it ".by_category filters" do
      ActivityLog.create!(user: user, action: "a", category: "scan")
      ActivityLog.create!(user: user, action: "b", category: "listing")
      expect(ActivityLog.by_category("scan").count).to eq(1)
    end
  end
end
