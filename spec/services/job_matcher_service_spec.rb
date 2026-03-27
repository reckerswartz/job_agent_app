require "rails_helper"

RSpec.describe JobMatcherService do
  let(:user) { create(:user) }
  let(:profile) { create(:profile, user: user, headline: "Senior Ruby on Rails Developer", contact_details: { "city" => "New York", "country" => "USA" }) }
  let(:source) { create(:job_source, user: user) }

  before do
    skills = profile.profile_sections.create!(section_type: "skills", title: "Skills")
    %w[Ruby Rails PostgreSQL].each do |skill|
      skills.profile_entries.create!(content: { "name" => skill })
    end
  end

  describe "#call" do
    it "returns a score between 0 and 100" do
      listing = build(:job_listing, job_source: source, title: "Ruby on Rails Developer", location: "New York")
      score = described_class.new(listing, profile).call
      expect(score).to be_between(0, 100)
    end

    it "scores higher for matching title keywords" do
      matching = build(:job_listing, job_source: source, title: "Senior Ruby Developer", location: "Remote")
      unmatched = build(:job_listing, job_source: source, title: "Java Spring Developer", location: "Remote")

      matching_score = described_class.new(matching, profile).call
      unmatched_score = described_class.new(unmatched, profile).call

      expect(matching_score).to be > unmatched_score
    end

    it "scores higher for matching location" do
      local = build(:job_listing, job_source: source, title: "Developer", location: "New York, NY")
      remote = build(:job_listing, job_source: source, title: "Developer", location: "London, UK")

      local_score = described_class.new(local, profile).call
      remote_score = described_class.new(remote, profile).call

      expect(local_score).to be > remote_score
    end

    it "returns 0 when no profile" do
      listing = build(:job_listing, job_source: source)
      score = described_class.new(listing, nil).call
      expect(score).to eq(0)
    end
  end
end
