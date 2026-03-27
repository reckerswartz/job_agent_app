require "rails_helper"

RSpec.describe NotificationMailer, type: :mailer do
  let(:user) { create(:user) }
  let(:source) { create(:job_source, user: user) }

  describe "#scan_completed" do
    let(:scan_run) { create(:job_scan_run, :completed, job_source: source) }

    it "sends email with correct subject and recipient" do
      mail = described_class.scan_completed(user, scan_run)
      expect(mail.to).to eq([user.email])
      expect(mail.subject).to include("Scan complete")
      expect(mail.subject).to include(source.name)
    end
  end

  describe "#new_matches" do
    let(:listings) { create_list(:job_listing, 3, :high_match, job_source: source) }

    it "sends email with listing count in subject" do
      mail = described_class.new_matches(user, listings)
      expect(mail.to).to eq([user.email])
      expect(mail.subject).to include("3 new high-match")
    end
  end

  describe "#application_status" do
    let(:listing) { create(:job_listing, job_source: source) }
    let(:profile) { create(:profile, user: user) }
    let(:application) { create(:job_application, :submitted, job_listing: listing, profile: profile) }

    it "sends email with status and listing info" do
      mail = described_class.application_status(user, application)
      expect(mail.to).to eq([user.email])
      expect(mail.subject).to include("Submitted")
      expect(mail.subject).to include(listing.title)
    end
  end

  describe "#intervention_needed" do
    let(:listing) { create(:job_listing, job_source: source) }
    let(:profile) { create(:profile, user: user) }
    let(:application) { create(:job_application, job_listing: listing, profile: profile) }
    let(:intervention) { create(:intervention, user: user, interventionable: application) }

    it "sends email with intervention type" do
      mail = described_class.intervention_needed(user, intervention)
      expect(mail.to).to eq([user.email])
      expect(mail.subject).to include("Action needed")
    end
  end
end
