require "rails_helper"

RSpec.describe JobListingNote, type: :model do
  let(:user) { create(:user) }
  let(:job_source) { create(:job_source, user: user) }
  let(:listing) { create(:job_listing, job_source: job_source) }

  describe "validations" do
    it "is valid with valid attributes" do
      note = build(:job_listing_note, job_listing: listing, user: user)
      expect(note).to be_valid
    end

    it "requires content" do
      note = build(:job_listing_note, job_listing: listing, user: user, content: nil)
      expect(note).not_to be_valid
      expect(note.errors[:content]).to include("can't be blank")
    end

    it "requires a job_listing" do
      note = build(:job_listing_note, job_listing: nil, user: user)
      expect(note).not_to be_valid
    end

    it "requires a user" do
      note = build(:job_listing_note, job_listing: listing, user: nil)
      expect(note).not_to be_valid
    end
  end

  describe "scopes" do
    it ".recent orders by created_at desc" do
      old = create(:job_listing_note, job_listing: listing, user: user, created_at: 2.days.ago)
      recent = create(:job_listing_note, job_listing: listing, user: user, created_at: 1.hour.ago)
      results = listing.job_listing_notes.recent
      expect(results.first).to eq(recent)
      expect(results.last).to eq(old)
    end
  end

  describe "associations" do
    it "is destroyed when listing is destroyed" do
      note = create(:job_listing_note, job_listing: listing, user: user)
      expect { listing.destroy }.to change(JobListingNote, :count).by(-1)
    end
  end
end
