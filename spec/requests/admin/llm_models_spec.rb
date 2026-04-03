require "rails_helper"

RSpec.describe "Admin::LlmModels", type: :request do
  let(:admin) { create(:user, role: :admin) }
  before { sign_in admin }

  describe "GET /admin/llm_models" do
    it "renders the models list" do
      provider = create(:llm_provider)
      create(:llm_model, llm_provider: provider)
      get admin_llm_models_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("LLM Model Configuration")
    end
  end

  describe "PATCH /admin/llm_models/:id" do
    it "updates model role" do
      provider = create(:llm_provider)
      model = create(:llm_model, llm_provider: provider, role: nil)
      patch admin_llm_model_path(model), params: { llm_model: { role: "primary_text", active: true } }
      expect(model.reload.role).to eq("primary_text")
      expect(response).to redirect_to(admin_llm_models_path)
    end

    it "toggles model active state" do
      provider = create(:llm_provider)
      model = create(:llm_model, llm_provider: provider, active: true)
      patch admin_llm_model_path(model), params: { llm_model: { active: false, role: model.role } }
      expect(model.reload.active).to be false
    end
  end

  context "as non-admin" do
    let(:regular_user) { create(:user, role: :user) }
    before { sign_in regular_user }

    it "denies access" do
      get admin_llm_models_path
      expect(response).to redirect_to(dashboard_path)
    end
  end
end
