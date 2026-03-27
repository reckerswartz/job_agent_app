require "rails_helper"

RSpec.describe "JobScanRuns", type: :request do
  let(:user) { create(:user) }
  let(:source) { create(:job_source, user: user) }

  before { sign_in user }

  describe "GET /job_sources/:id/scan_runs" do
    it "renders the index page" do
      create(:job_scan_run, :completed, job_source: source)
      get job_source_scan_runs_path(source)
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Scan History")
    end
  end

  describe "POST /job_sources/:id/scan_runs" do
    it "enqueues a scan job and redirects" do
      expect {
        post job_source_scan_runs_path(source)
      }.to have_enqueued_job(JobScanJob)

      expect(response).to redirect_to(job_source_scan_runs_path(source))
    end
  end

  describe "GET /job_sources/:id/scan_runs/:id" do
    it "renders the show page" do
      run = create(:job_scan_run, :completed, job_source: source)
      get job_source_scan_run_path(source, run)
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Scan Run ##{run.id}")
    end
  end
end
