require "rails_helper"

RSpec.describe "API v1 Job Listing Notes", type: :request do
  let(:user) { create(:user) }
  let(:token) { user.generate_api_token! }
  let(:headers) { { "Authorization" => "Bearer #{token}", "Content-Type" => "application/json" } }
  let(:job_source) { create(:job_source, user: user) }
  let(:listing) { create(:job_listing, job_source: job_source) }

  describe "GET /api/v1/job_listings/:id/notes" do
    it "returns the user's notes for a listing" do
      create(:job_listing_note, job_listing: listing, user: user, content: "Note 1")
      create(:job_listing_note, job_listing: listing, user: user, content: "Note 2")

      get "/api/v1/job_listings/#{listing.id}/notes", headers: headers
      expect(response).to have_http_status(:ok)
      data = JSON.parse(response.body)["data"]
      expect(data.size).to eq(2)
      expect(data.first).to have_key("content")
    end

    it "does not return other users' notes" do
      other = create(:user)
      create(:job_listing_note, job_listing: listing, user: other, content: "Secret")

      get "/api/v1/job_listings/#{listing.id}/notes", headers: headers
      data = JSON.parse(response.body)["data"]
      expect(data.size).to eq(0)
    end
  end

  describe "POST /api/v1/job_listings/:id/notes" do
    it "creates a note" do
      expect {
        post "/api/v1/job_listings/#{listing.id}/notes", headers: headers,
             params: { content: "Great opportunity" }.to_json
      }.to change(JobListingNote, :count).by(1)

      expect(response).to have_http_status(:created)
      data = JSON.parse(response.body)["data"]
      expect(data["content"]).to eq("Great opportunity")
    end

    it "rejects blank content" do
      post "/api/v1/job_listings/#{listing.id}/notes", headers: headers,
           params: { content: "" }.to_json
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "DELETE /api/v1/job_listings/:id/notes/:note_id" do
    it "deletes the user's own note" do
      note = create(:job_listing_note, job_listing: listing, user: user)
      expect {
        delete "/api/v1/job_listings/#{listing.id}/notes/#{note.id}", headers: headers
      }.to change(JobListingNote, :count).by(-1)
      expect(response).to have_http_status(:no_content)
    end
  end
end
