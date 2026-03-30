require "rails_helper"

RSpec.describe AnalyticsService do
  let(:user) { create(:user) }
  let(:source) { create(:job_source, user: user) }
  let(:service) { described_class.new(user) }

  describe "#listings_over_time" do
    it "returns a hash of weekly counts" do
      create(:job_listing, job_source: source)
      result = service.listings_over_time
      expect(result).to be_a(Hash)
      expect(result.values.sum).to eq(1)
    end
  end

  describe "#match_score_distribution" do
    it "returns low/medium/high buckets" do
      create(:job_listing, :low_match, job_source: source)
      create(:job_listing, :medium_match, job_source: source)
      create(:job_listing, :high_match, job_source: source)
      result = service.match_score_distribution
      expect(result.keys).to eq([ "Low (0-39)", "Medium (40-69)", "High (70-100)" ])
      expect(result.values.sum).to eq(3)
    end
  end

  describe "#applications_by_status" do
    it "groups applications by status" do
      profile = create(:profile, user: user)
      listing = create(:job_listing, job_source: source)
      create(:job_application, :submitted, job_listing: listing, profile: profile)
      result = service.applications_by_status
      expect(result["submitted"]).to eq(1)
    end
  end

  describe "#source_performance" do
    it "counts listings per platform" do
      create(:job_listing, job_source: source)
      result = service.source_performance
      expect(result["Linkedin"]).to eq(1)
    end
  end

  describe "#scan_activity" do
    it "returns weekly scan counts" do
      create(:job_scan_run, :completed, job_source: source)
      result = service.scan_activity
      expect(result).to be_a(Hash)
      expect(result.values.sum).to eq(1)
    end
  end

  describe "#top_companies" do
    it "returns top companies by listing count" do
      create(:job_listing, job_source: source, company: "Acme")
      create(:job_listing, job_source: source, company: "Acme")
      create(:job_listing, job_source: source, company: "Other")
      result = service.top_companies
      expect(result.keys.first).to eq("Acme")
      expect(result["Acme"]).to eq(2)
    end
  end
end
