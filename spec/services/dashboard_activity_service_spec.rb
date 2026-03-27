require "rails_helper"

RSpec.describe DashboardActivityService do
  let(:user) { create(:user) }
  let(:source) { create(:job_source, user: user) }

  describe "#call" do
    it "returns an empty array when no activity" do
      result = described_class.new(user).call
      expect(result).to eq([])
    end

    it "includes completed scan runs" do
      create(:job_scan_run, :completed, job_source: source)
      result = described_class.new(user).call
      expect(result.any? { |e| e[:type] == "scan" }).to be true
    end

    it "includes high-match listings" do
      create(:job_listing, :high_match, job_source: source)
      result = described_class.new(user).call
      expect(result.any? { |e| e[:type] == "match" }).to be true
    end

    it "includes submitted applications" do
      profile = create(:profile, user: user)
      listing = create(:job_listing, job_source: source)
      create(:job_application, :submitted, job_listing: listing, profile: profile)
      result = described_class.new(user).call
      expect(result.any? { |e| e[:type] == "applied" }).to be true
    end

    it "includes pending interventions" do
      profile = create(:profile, user: user)
      listing = create(:job_listing, job_source: source)
      app = create(:job_application, job_listing: listing, profile: profile)
      create(:intervention, user: user, interventionable: app)
      result = described_class.new(user).call
      expect(result.any? { |e| e[:type] == "alert" }).to be true
    end

    it "sorts by time descending and limits to 10" do
      12.times { create(:job_listing, :high_match, job_source: source) }
      result = described_class.new(user).call
      expect(result.size).to be <= 10
      times = result.map { |e| e[:time] }
      expect(times).to eq(times.sort.reverse)
    end
  end
end
