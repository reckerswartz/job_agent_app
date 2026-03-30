require "rails_helper"

RSpec.describe "Admin::LlmInteractions", type: :request do
  let(:admin) { create(:user, role: :admin) }
  before { sign_in admin }

  describe "GET /admin/llm_interactions" do
    it "renders interactions list" do
      get admin_llm_interactions_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("LLM Interactions")
    end
  end

  describe "GET /admin/llm_interactions/:id" do
    it "renders interaction detail" do
      interaction = create(:llm_interaction, user: admin)
      get admin_llm_interaction_path(interaction)
      expect(response).to have_http_status(:success)
      expect(response.body).to include("LLM Interaction ##{interaction.id}")
    end
  end
end
