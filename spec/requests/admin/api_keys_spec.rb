require "rails_helper"

RSpec.describe "Admin::ApiKeys", type: :request do
  let(:admin) { create(:user, role: :admin) }
  before { sign_in admin }

  describe "GET /admin/api_keys" do
    it "renders the API keys page" do
      get admin_api_keys_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("API Keys")
    end
  end

  describe "PATCH /admin/api_keys" do
    it "saves an API key" do
      patch admin_api_keys_path, params: { settings: { "nvidia_api_key" => "test-key-123" } }
      expect(response).to redirect_to(admin_api_keys_path)
      expect(AppSetting.get("nvidia_api_key")).to eq("test-key-123")
    end

    it "ignores unknown keys" do
      patch admin_api_keys_path, params: { settings: { "unknown_key" => "value" } }
      expect(AppSetting.find_by(key: "unknown_key")).to be_nil
    end
  end

  context "as non-admin" do
    let(:regular_user) { create(:user, role: :user) }
    before { sign_in regular_user }

    it "denies access" do
      get admin_api_keys_path
      expect(response).to redirect_to(dashboard_path)
    end
  end
end
