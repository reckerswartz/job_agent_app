require "rails_helper"

RSpec.describe WebhookDeliveryJob, type: :job do
  let(:user) { create(:user) }
  let(:endpoint) { create(:webhook_endpoint, user: user, active: true, url: "https://example.com/hook") }

  describe "#perform" do
    let(:mock_http) { instance_double(Net::HTTP) }
    let(:mock_response) { instance_double(Net::HTTPResponse, code: "200") }

    before do
      allow(Net::HTTP).to receive(:new).and_return(mock_http)
      allow(mock_http).to receive(:use_ssl=)
      allow(mock_http).to receive(:read_timeout=)
      allow(mock_http).to receive(:open_timeout=)
      allow(mock_http).to receive(:request).and_return(mock_response)
    end

    it "sends a POST request to the endpoint URL" do
      described_class.new.perform(endpoint.id, "scan.completed", { listings: 5 })
      expect(mock_http).to have_received(:request).once
    end

    it "uses SSL for https URLs" do
      described_class.new.perform(endpoint.id, "scan.completed", {})
      expect(mock_http).to have_received(:use_ssl=).with(true)
    end

    it "skips delivery for inactive endpoints" do
      endpoint.update!(active: false)
      expect(Net::HTTP).not_to receive(:new)
      described_class.new.perform(endpoint.id, "scan.completed", {})
    end

    it "handles network errors gracefully" do
      allow(mock_http).to receive(:request).and_raise(Errno::ECONNREFUSED)
      expect { described_class.new.perform(endpoint.id, "scan.completed", {}) }.not_to raise_error
    end
  end
end
