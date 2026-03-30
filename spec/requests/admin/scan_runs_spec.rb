require "rails_helper"

RSpec.describe "Admin::ScanRuns", type: :request do
  let(:admin) { create(:user, role: :admin) }
  before { sign_in admin }

  describe "GET /admin/scan_runs" do
    it "renders scan runs list" do
      source = create(:job_source, user: admin)
      create(:job_scan_run, :completed, job_source: source)
      get admin_scan_runs_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Scan Runs")
    end
  end

  describe "GET /admin/scan_runs/:id" do
    it "renders scan run detail" do
      source = create(:job_source, user: admin)
      run = create(:job_scan_run, :completed, job_source: source)
      get admin_scan_run_path(run)
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Scan Run ##{run.id}")
    end
  end
end
