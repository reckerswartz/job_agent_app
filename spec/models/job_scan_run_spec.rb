require "rails_helper"

RSpec.describe JobScanRun, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:job_source) }
    it { is_expected.to belong_to(:job_search_criteria).optional }
  end

  describe "validations" do
    it { is_expected.to validate_inclusion_of(:status).in_array(JobScanRun::STATUSES) }
  end

  describe "#mark_completed!" do
    it "updates status and counts" do
      run = create(:job_scan_run, :running)
      run.mark_completed!(found: 10, new_count: 5)
      expect(run.status).to eq("completed")
      expect(run.listings_found).to eq(10)
      expect(run.new_listings).to eq(5)
      expect(run.duration_ms).to be > 0
    end
  end

  describe "#mark_failed!" do
    it "records error details" do
      run = create(:job_scan_run, :running)
      error = StandardError.new("test error")
      run.mark_failed!(error)
      expect(run.status).to eq("failed")
      expect(run.error_details["message"]).to eq("test error")
    end
  end

  describe "#duration_display" do
    it "formats seconds" do
      run = build(:job_scan_run, duration_ms: 5500)
      expect(run.duration_display).to eq("5.5s")
    end

    it "formats minutes" do
      run = build(:job_scan_run, duration_ms: 125_000)
      expect(run.duration_display).to eq("2m 5s")
    end

    it "returns dash when nil" do
      run = build(:job_scan_run, duration_ms: nil)
      expect(run.duration_display).to eq("—")
    end
  end
end
