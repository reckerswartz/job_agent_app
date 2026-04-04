require "rails_helper"

RSpec.describe "Interviews", type: :request do
  let(:user) { create(:user) }
  let(:job_source) { create(:job_source, user: user) }
  let(:job_listing) { create(:job_listing, job_source: job_source) }
  let(:profile) { create(:profile, user: user) }
  let(:application) { create(:job_application, job_listing: job_listing, profile: profile) }

  before { sign_in user }

  describe "POST /job_applications/:id/interviews" do
    it "creates an interview" do
      expect {
        post job_application_interviews_path(application), params: {
          interview: { stage: "technical", status: "scheduled", scheduled_at: 3.days.from_now, format: "video" }
        }
      }.to change(Interview, :count).by(1)

      expect(response).to redirect_to(job_application_path(application))
    end

    it "rejects invalid interview" do
      post job_application_interviews_path(application), params: {
        interview: { stage: "", status: "scheduled" }
      }
      expect(response).to redirect_to(job_application_path(application))
      expect(flash[:alert]).to be_present
    end
  end

  describe "PATCH /job_applications/:id/interviews/:interview_id" do
    let!(:interview) { create(:interview, job_application: application) }

    it "updates the interview" do
      patch job_application_interview_path(application, interview), params: {
        interview: { rating: 5, status: "completed" }
      }
      expect(response).to redirect_to(job_application_path(application))
      expect(interview.reload.rating).to eq(5)
      expect(interview.reload.status).to eq("completed")
    end
  end

  describe "DELETE /job_applications/:id/interviews/:interview_id" do
    let!(:interview) { create(:interview, job_application: application) }

    it "destroys the interview" do
      expect {
        delete job_application_interview_path(application, interview)
      }.to change(Interview, :count).by(-1)
      expect(response).to redirect_to(job_application_path(application))
    end
  end

  context "when not authenticated" do
    before { sign_out user }

    it "redirects to sign in" do
      post job_application_interviews_path(application), params: {
        interview: { stage: "technical", status: "scheduled" }
      }
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
