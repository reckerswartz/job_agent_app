require "rails_helper"

RSpec.describe WebhookEndpoint, type: :model do
  let(:user) { create(:user) }
  let(:endpoint) { build(:webhook_endpoint, user: user) }

  describe "validations" do
    it "is valid with valid attributes" do
      expect(endpoint).to be_valid
    end

    it "requires url" do
      endpoint.url = nil
      expect(endpoint).not_to be_valid
    end

    it "rejects invalid url format" do
      endpoint.url = "not-a-url"
      expect(endpoint).not_to be_valid
    end

    it "accepts https url" do
      endpoint.url = "https://example.com/webhooks"
      expect(endpoint).to be_valid
    end

    it "requires events" do
      endpoint.events = nil
      expect(endpoint).not_to be_valid
    end
  end

  describe "secret generation" do
    it "generates a secret on create" do
      endpoint.save!
      expect(endpoint.secret).to be_present
      expect(endpoint.secret.length).to eq(40)
    end

    it "does not overwrite an existing secret" do
      endpoint.secret = "custom_secret_value"
      endpoint.save!
      expect(endpoint.secret).to eq("custom_secret_value")
    end
  end

  describe "scopes" do
    it ".active returns only active endpoints" do
      active = create(:webhook_endpoint, user: user, active: true)
      create(:webhook_endpoint, user: user, active: false)
      expect(WebhookEndpoint.active).to contain_exactly(active)
    end

    it ".for_event returns endpoints subscribed to the event" do
      scan_ep = create(:webhook_endpoint, user: user, events: [ "scan.completed" ], active: true)
      create(:webhook_endpoint, user: user, events: [ "listing.new" ], active: true)
      expect(WebhookEndpoint.for_event("scan.completed")).to contain_exactly(scan_ep)
    end
  end
end
