require "rails_helper"

RSpec.describe "JobListingNotes", type: :request do
  let(:user) { create(:user) }
  let(:job_source) { create(:job_source, user: user) }
  let(:listing) { create(:job_listing, job_source: job_source) }

  before { sign_in user }

  describe "POST /job_listings/:id/notes" do
    it "creates a note" do
      expect {
        post job_listing_notes_path(listing), params: {
          job_listing_note: { content: "Great opportunity!" }
        }
      }.to change(JobListingNote, :count).by(1)

      expect(response).to redirect_to(job_listing_path(listing))
      expect(JobListingNote.last.content).to eq("Great opportunity!")
      expect(JobListingNote.last.user).to eq(user)
    end

    it "rejects blank content" do
      post job_listing_notes_path(listing), params: {
        job_listing_note: { content: "" }
      }
      expect(response).to redirect_to(job_listing_path(listing))
      expect(flash[:alert]).to be_present
    end
  end

  describe "DELETE /job_listings/:id/notes/:note_id" do
    it "deletes the user's own note" do
      note = create(:job_listing_note, job_listing: listing, user: user)
      expect {
        delete job_listing_note_path(listing, note)
      }.to change(JobListingNote, :count).by(-1)
      expect(response).to redirect_to(job_listing_path(listing))
    end

    it "cannot delete another user's note" do
      other_user = create(:user)
      note = create(:job_listing_note, job_listing: listing, user: other_user)
      delete job_listing_note_path(listing, note)
      # RecordNotFound rescued by ApplicationController → redirects to dashboard
      expect(response).to redirect_to(dashboard_path)
    end
  end

  context "when not authenticated" do
    before { sign_out user }

    it "redirects to sign in" do
      post job_listing_notes_path(listing), params: {
        job_listing_note: { content: "Test" }
      }
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
