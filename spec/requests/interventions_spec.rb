require "rails_helper"

RSpec.describe "Interventions", type: :request do
  let(:user) { create(:user) }
  let(:source) { create(:job_source, user: user) }
  let(:listing) { create(:job_listing, job_source: source) }
  let!(:profile) { create(:profile, user: user) }
  let(:application) { create(:job_application, job_listing: listing, profile: profile) }

  before { sign_in user }

  describe "GET /interventions" do
    it "renders the index page" do
      create(:intervention, user: user, interventionable: application)
      get interventions_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Interventions")
    end

    it "filters by status" do
      create(:intervention, user: user, interventionable: application)
      get interventions_path(status: "pending")
      expect(response).to have_http_status(:success)
    end

    it "shows empty state when no interventions" do
      get interventions_path
      expect(response.body).to include("No pending interventions")
    end
  end

  describe "GET /interventions/:id" do
    it "renders the show page with type-specific form" do
      intervention = create(:intervention, :login_required, user: user, interventionable: application)
      get intervention_path(intervention)
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Login required")
      expect(response.body).to include("Resolve")
    end
  end

  describe "PATCH /interventions/:id/resolve" do
    it "resolves the intervention" do
      intervention = create(:intervention, user: user, interventionable: application)
      patch resolve_intervention_path(intervention), params: {
        user_input: { username: "test@example.com", password: "secret" }
      }
      expect(intervention.reload.status).to eq("resolved")
      expect(intervention.user_input["username"]).to eq("test@example.com")
      expect(response).to redirect_to(interventions_path)
    end
  end

  describe "PATCH /interventions/:id/dismiss" do
    it "dismisses the intervention" do
      intervention = create(:intervention, user: user, interventionable: application)
      patch dismiss_intervention_path(intervention)
      expect(intervention.reload.status).to eq("dismissed")
      expect(response).to redirect_to(interventions_path)
    end
  end
end
