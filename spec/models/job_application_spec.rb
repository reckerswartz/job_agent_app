require "rails_helper"

RSpec.describe JobApplication, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:job_listing) }
    it { is_expected.to belong_to(:profile) }
    it { is_expected.to have_many(:application_steps).dependent(:destroy) }
  end

  describe "validations" do
    it { is_expected.to validate_inclusion_of(:status).in_array(JobApplication::STATUSES) }

    it "enforces one application per listing" do
      app = create(:job_application)
      duplicate = build(:job_application, job_listing: app.job_listing)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:job_listing_id]).to include("already has an application")
    end
  end

  describe "status transitions" do
    let(:app) { create(:job_application) }

    it "#mark_submitted! sets status and applied_at" do
      app.mark_submitted!
      expect(app.status).to eq("submitted")
      expect(app.applied_at).to be_present
    end

    it "#mark_failed! records error details" do
      app.mark_failed!(StandardError.new("test error"))
      expect(app.status).to eq("failed")
      expect(app.error_details["message"]).to eq("test error")
    end

    it "#mark_needs_intervention! records reason" do
      app.mark_needs_intervention!("Login required")
      expect(app.status).to eq("needs_intervention")
      expect(app.error_details["reason"]).to eq("Login required")
    end
  end

  describe "#can_retry?" do
    it "returns true for failed applications" do
      app = build(:job_application, :failed)
      expect(app.can_retry?).to be true
    end

    it "returns true for needs_intervention" do
      app = build(:job_application, :needs_intervention)
      expect(app.can_retry?).to be true
    end

    it "returns false for submitted applications" do
      app = build(:job_application, :submitted)
      expect(app.can_retry?).to be false
    end
  end

  describe "scopes" do
    let(:user) { create(:user) }
    let(:source) { create(:job_source, user: user) }
    let(:listing) { create(:job_listing, job_source: source) }

    it ".for_user scopes to user's applications" do
      app = create(:job_application, job_listing: listing)
      other_listing = create(:job_listing)
      create(:job_application, job_listing: other_listing)
      expect(JobApplication.for_user(user)).to eq([app])
    end
  end
end
