require "rails_helper"

RSpec.describe JobListing, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:job_source) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_inclusion_of(:status).in_array(JobListing::STATUSES) }
  end

  describe "#match_level" do
    it "returns high for scores >= 70" do
      listing = build(:job_listing, match_score: 85)
      expect(listing.match_level).to eq("high")
    end

    it "returns medium for scores 40-69" do
      listing = build(:job_listing, match_score: 55)
      expect(listing.match_level).to eq("medium")
    end

    it "returns low for scores < 40" do
      listing = build(:job_listing, match_score: 20)
      expect(listing.match_level).to eq("low")
    end

    it "returns nil when no score" do
      listing = build(:job_listing, match_score: nil)
      expect(listing.match_level).to be_nil
    end
  end

  describe "scopes" do
    let(:user) { create(:user) }
    let(:source) { create(:job_source, user: user) }

    it ".by_status filters by status" do
      saved = create(:job_listing, :saved, job_source: source)
      create(:job_listing, job_source: source, status: "new")
      expect(JobListing.by_status("saved")).to eq([saved])
    end

    it ".high_match returns listings with score >= 70" do
      high = create(:job_listing, :high_match, job_source: source)
      create(:job_listing, :low_match, job_source: source)
      expect(JobListing.high_match).to include(high)
    end

    it ".for_user scopes to user's sources" do
      mine = create(:job_listing, job_source: source)
      other_source = create(:job_source)
      create(:job_listing, job_source: other_source)
      expect(JobListing.for_user(user)).to eq([mine])
    end
  end
end
