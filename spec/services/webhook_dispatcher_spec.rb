require "rails_helper"

RSpec.describe WebhookDispatcher do
  let(:user) { create(:user) }

  describe ".fire" do
    it "enqueues delivery jobs for matching active endpoints" do
      endpoint = create(:webhook_endpoint, user: user, events: ["scan.completed"], active: true)
      create(:webhook_endpoint, user: user, events: ["listing.new"], active: true)

      expect {
        described_class.fire(user, "scan.completed", { listings: 5 })
      }.to have_enqueued_job(WebhookDeliveryJob)
    end

    it "skips inactive endpoints" do
      create(:webhook_endpoint, user: user, events: ["scan.completed"], active: false)

      expect {
        described_class.fire(user, "scan.completed", {})
      }.not_to have_enqueued_job(WebhookDeliveryJob)
    end

    it "does nothing when no endpoints match the event" do
      create(:webhook_endpoint, user: user, events: ["listing.new"], active: true)

      expect {
        described_class.fire(user, "scan.completed", {})
      }.not_to have_enqueued_job(WebhookDeliveryJob)
    end
  end
end
