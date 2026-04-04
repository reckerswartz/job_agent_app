require "rails_helper"

RSpec.describe ActivityLogger do
  let(:user) { create(:user) }

  describe ".log" do
    it "creates an activity log entry" do
      log = described_class.log(user: user, action: "scan_completed", category: "scan", description: "Test scan")
      expect(log).to be_a(ActivityLog)
      expect(log).to be_persisted
      expect(log.action).to eq("scan_completed")
      expect(log.category).to eq("scan")
      expect(log.description).to eq("Test scan")
    end

    it "supports trackable polymorphic association" do
      source = create(:job_source, user: user)
      log = described_class.log(user: user, action: "source_created", trackable: source)
      expect(log.trackable).to eq(source)
    end

    it "stores metadata and IP" do
      log = described_class.log(user: user, action: "login", metadata: { browser: "Chrome" }, ip: "127.0.0.1")
      expect(log.metadata).to eq({ "browser" => "Chrome" })
      expect(log.ip_address).to eq("127.0.0.1")
    end

    it "returns nil on failure" do
      allow(user).to receive_message_chain(:activity_logs, :create!).and_raise(ActiveRecord::RecordInvalid)
      result = described_class.log(user: user, action: nil)
      expect(result).to be_nil
    end
  end
end
