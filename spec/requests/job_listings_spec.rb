require "rails_helper"

RSpec.describe "JobListings", type: :request do
  let(:user) { create(:user) }
  let(:source) { create(:job_source, user: user) }

  before { sign_in user }

  describe "GET /job_listings" do
    it "renders the index page" do
      create(:job_listing, job_source: source)
      get job_listings_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Job Listings")
    end

    it "filters by status" do
      create(:job_listing, :saved, job_source: source, title: "Saved Job")
      create(:job_listing, job_source: source, title: "New Job", status: "new")
      get job_listings_path(status: "saved")
      expect(response.body).to include("Saved Job")
      expect(response.body).not_to include("New Job")
    end
  end

  describe "GET /job_listings/:id" do
    it "renders the show page" do
      listing = create(:job_listing, job_source: source, description: "Great role")
      get job_listing_path(listing)
      expect(response).to have_http_status(:success)
      expect(response.body).to include(listing.title)
    end
  end

  describe "PATCH /job_listings/:id/update_status" do
    let!(:listing) { create(:job_listing, job_source: source, status: "new") }

    it "updates the status" do
      patch update_status_job_listing_path(listing, new_status: "saved")
      expect(listing.reload.status).to eq("saved")
    end

    it "rejects invalid status" do
      patch update_status_job_listing_path(listing, new_status: "invalid")
      expect(response).to redirect_to(job_listings_path)
      expect(flash[:alert]).to be_present
    end
  end

  describe "POST /job_listings/:id/generate_cover_letter" do
    let!(:listing) { create(:job_listing, job_source: source) }
    let!(:profile) { create(:profile, user: user) }

    it "enqueues a cover letter job and redirects" do
      expect {
        post generate_cover_letter_job_listing_path(listing)
      }.to have_enqueued_job(CoverLetterJob)

      expect(response).to redirect_to(job_listing_path(listing))
    end
  end

  describe "POST /job_listings/bulk_update" do
    let!(:listing1) { create(:job_listing, job_source: source, status: "new") }
    let!(:listing2) { create(:job_listing, job_source: source, status: "new") }

    it "updates multiple listings" do
      post bulk_update_job_listings_path, params: { ids: [ listing1.id, listing2.id ], new_status: "saved" }
      expect(listing1.reload.status).to eq("saved")
      expect(listing2.reload.status).to eq("saved")
      expect(response).to redirect_to(job_listings_path)
    end

    it "rejects invalid status" do
      post bulk_update_job_listings_path, params: { ids: [ listing1.id ], new_status: "invalid" }
      expect(response).to redirect_to(job_listings_path)
      expect(flash[:alert]).to be_present
    end
  end
end
