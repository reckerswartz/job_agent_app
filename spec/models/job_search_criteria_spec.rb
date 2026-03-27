require "rails_helper"

RSpec.describe JobSearchCriteria, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_inclusion_of(:remote_preference).in_array(JobSearchCriteria::REMOTE_PREFERENCES) }
    it { is_expected.to validate_inclusion_of(:job_type).in_array(JobSearchCriteria::JOB_TYPES) }
  end

  describe "#summary" do
    it "returns a combined summary string" do
      criteria = build(:job_search_criteria, keywords: "Rails", location: "NYC", remote_preference: "remote")
      expect(criteria.summary).to include("Rails")
      expect(criteria.summary).to include("NYC")
      expect(criteria.summary).to include("Remote")
    end

    it "includes salary range when set" do
      criteria = build(:job_search_criteria, :with_salary)
      expect(criteria.summary).to include("$50,000")
    end
  end

  describe "single default" do
    let(:user) { create(:user) }

    it "ensures only one default per user" do
      first = create(:job_search_criteria, :default, user: user)
      second = create(:job_search_criteria, :default, user: user)

      expect(first.reload.is_default).to be false
      expect(second.reload.is_default).to be true
    end
  end
end
