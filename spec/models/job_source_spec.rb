require "rails_helper"

RSpec.describe JobSource, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:platform) }
    it { is_expected.to validate_inclusion_of(:platform).in_array(JobSource::PLATFORMS) }
    it { is_expected.to validate_inclusion_of(:status).in_array(JobSource::STATUSES) }
  end

  describe "auto base_url" do
    it "sets base_url for known platforms" do
      source = build(:job_source, platform: "linkedin", base_url: nil)
      source.valid?
      expect(source.base_url).to eq("https://www.linkedin.com/jobs/search/")
    end

    it "does not override existing base_url" do
      source = build(:job_source, platform: "custom", base_url: "https://custom.jobs")
      source.valid?
      expect(source.base_url).to eq("https://custom.jobs")
    end
  end

  describe "#due_for_scan?" do
    it "returns true when never scanned" do
      source = build(:job_source, last_scanned_at: nil)
      expect(source).to be_due_for_scan
    end

    it "returns true when scan interval has passed" do
      source = build(:job_source, last_scanned_at: 7.hours.ago, scan_interval_hours: 6)
      expect(source).to be_due_for_scan
    end

    it "returns false when recently scanned" do
      source = build(:job_source, last_scanned_at: 1.hour.ago, scan_interval_hours: 6)
      expect(source).not_to be_due_for_scan
    end
  end

  describe "scopes" do
    let(:user) { create(:user) }

    it ".enabled returns only enabled sources" do
      enabled = create(:job_source, user: user, enabled: true)
      create(:job_source, :disabled, user: user)
      expect(JobSource.enabled).to eq([ enabled ])
    end
  end
end
