require "rails_helper"

RSpec.describe InterventionCreator do
  let(:user) { create(:user) }
  let(:job_source) { create(:job_source, user: user) }

  describe ".create_for" do
    it "creates an intervention" do
      intervention = described_class.create_for(
        job_source, type: "login_required", context: { message: "Session expired" }, user: user
      )
      expect(intervention).to be_a(Intervention)
      expect(intervention).to be_persisted
      expect(intervention.intervention_type).to eq("login_required")
      expect(intervention.status).to eq("pending")
    end

    it "sends email when user has interventions notification enabled" do
      user.update!(notification_settings: { "email_interventions" => true })
      expect {
        described_class.create_for(job_source, type: "captcha", context: {}, user: user)
      }.to have_enqueued_mail(NotificationMailer, :intervention_needed)
    end

    it "skips email when user has interventions notification disabled" do
      user.update!(notification_settings: { "email_interventions" => false })
      expect {
        described_class.create_for(job_source, type: "captcha", context: {}, user: user)
      }.not_to have_enqueued_mail(NotificationMailer, :intervention_needed)
    end
  end
end
