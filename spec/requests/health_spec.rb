require "rails_helper"

RSpec.describe "Health", type: :request do
  describe "GET /health" do
    it "returns JSON with system status fields" do
      get health_path
      expect(response.content_type).to include("application/json")
      json = JSON.parse(response.body)
      expect(json).to have_key("status")
      expect(json["database"]).to eq("ok")
      expect(json).to have_key("users")
      expect(json).to have_key("listings")
      expect(json).to have_key("uptime")
    end

    it "includes model counts as integers" do
      get health_path
      json = JSON.parse(response.body)
      expect(json["users"]).to be_a(Integer)
      expect(json["listings"]).to be_a(Integer)
      expect(json["models_active"]).to be_a(Integer)
    end

    it "does not require authentication" do
      get health_path
      # May return 200 (ok) or 503 (degraded) depending on LLM config, but never 401/302
      expect(response).to have_http_status(:ok).or have_http_status(:service_unavailable)
    end
  end
end
