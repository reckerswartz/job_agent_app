require "rails_helper"

RSpec.describe "JobApplications", type: :request do
  let(:user) { create(:user) }
  let(:source) { create(:job_source, user: user) }
  let(:listing) { create(:job_listing, job_source: source) }
  let!(:profile) { create(:profile, user: user) }

  before { sign_in user }

  describe "GET /job_applications" do
    it "renders the index page" do
      create(:job_application, job_listing: listing, profile: profile)
      get job_applications_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Applications")
    end

    it "filters by status" do
      create(:job_application, :submitted, job_listing: listing, profile: profile)
      get job_applications_path(status: "submitted")
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /job_applications/:id" do
    it "renders the show page" do
      app = create(:job_application, job_listing: listing, profile: profile)
      create(:application_step, :completed, job_application: app, action: "navigate")
      get job_application_path(app)
      expect(response).to have_http_status(:success)
      expect(response.body).to include(listing.title)
    end
  end

  describe "POST /job_applications" do
    it "creates an application and enqueues job" do
      expect {
        post job_applications_path, params: { job_listing_id: listing.id }
      }.to change(JobApplication, :count).by(1)
        .and have_enqueued_job(JobApplyJob)

      expect(response).to redirect_to(job_application_path(JobApplication.last))
    end

    it "rejects duplicate application" do
      create(:job_application, job_listing: listing, profile: profile)
      post job_applications_path, params: { job_listing_id: listing.id }
      expect(response).to redirect_to(job_listing_path(listing))
      expect(flash[:alert]).to include("already has an application")
    end
  end

  describe "POST /job_applications/:id/retry_application" do
    it "retries a failed application" do
      app = create(:job_application, :failed, job_listing: listing, profile: profile)
      create(:application_step, :failed, job_application: app, action: "navigate")

      expect {
        post retry_application_job_application_path(app)
      }.to have_enqueued_job(JobApplyJob)

      expect(app.reload.status).to eq("queued")
      expect(app.application_steps.count).to eq(0)
    end

    it "rejects retry on submitted application" do
      app = create(:job_application, :submitted, job_listing: listing, profile: profile)
      post retry_application_job_application_path(app)
      expect(response).to redirect_to(job_application_path(app))
      expect(flash[:alert]).to include("cannot be retried")
    end
  end
end
