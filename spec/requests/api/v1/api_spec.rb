require "rails_helper"

RSpec.describe "API v1", type: :request do
  let(:user) { create(:user) }
  let(:token) { user.generate_api_token! }
  let(:headers) { { "Authorization" => "Bearer #{token}" } }

  describe "authentication" do
    it "rejects requests without token" do
      get "/api/v1/job_listings"
      expect(response).to have_http_status(:unauthorized)
      expect(JSON.parse(response.body)["error"]).to include("Unauthorized")
    end

    it "rejects invalid token" do
      get "/api/v1/job_listings", headers: { "Authorization" => "Bearer invalid" }
      expect(response).to have_http_status(:unauthorized)
    end

    it "accepts valid token" do
      get "/api/v1/job_listings", headers: headers
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /api/v1/job_listings" do
    it "returns paginated listings" do
      source = create(:job_source, user: user)
      create_list(:job_listing, 3, job_source: source)

      get "/api/v1/job_listings", headers: headers
      body = JSON.parse(response.body)
      expect(body["data"].size).to eq(3)
      expect(body["meta"]["total"]).to eq(3)
    end

    it "filters by status" do
      source = create(:job_source, user: user)
      create(:job_listing, job_source: source, status: "saved")
      create(:job_listing, job_source: source, status: "new")

      get "/api/v1/job_listings", params: { status: "saved" }, headers: headers
      body = JSON.parse(response.body)
      expect(body["data"].size).to eq(1)
      expect(body["data"][0]["status"]).to eq("saved")
    end
  end

  describe "GET /api/v1/job_listings/:id" do
    it "returns a listing" do
      source = create(:job_source, user: user)
      listing = create(:job_listing, job_source: source)

      get "/api/v1/job_listings/#{listing.id}", headers: headers
      body = JSON.parse(response.body)
      expect(body["data"]["id"]).to eq(listing.id)
      expect(body["data"]["title"]).to eq(listing.title)
    end
  end

  describe "GET /api/v1/job_sources" do
    it "returns user sources" do
      create(:job_source, user: user, name: "My LinkedIn")

      get "/api/v1/job_sources", headers: headers
      body = JSON.parse(response.body)
      expect(body["data"].size).to eq(1)
      expect(body["data"][0]["name"]).to eq("My LinkedIn")
    end
  end

  describe "GET /api/v1/profile" do
    it "returns user profile" do
      create(:profile, user: user, headline: "Ruby Dev")

      get "/api/v1/profile", headers: headers
      body = JSON.parse(response.body)
      expect(body["data"]["headline"]).to eq("Ruby Dev")
      expect(body["data"]["completeness"]).to be_a(Integer)
    end
  end

  describe "GET /api/v1/scan_runs" do
    it "returns user scan runs" do
      source = create(:job_source, user: user)
      create(:job_scan_run, :completed, job_source: source)

      get "/api/v1/scan_runs", headers: headers
      body = JSON.parse(response.body)
      expect(body["data"].size).to eq(1)
    end
  end
end
