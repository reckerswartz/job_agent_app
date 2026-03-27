require "rails_helper"

RSpec.describe LlmInteraction, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:profile).optional }
    it { is_expected.to belong_to(:llm_provider).optional }
    it { is_expected.to belong_to(:llm_model).optional }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:feature_name) }
    it { is_expected.to validate_inclusion_of(:feature_name).in_array(LlmInteraction::FEATURES) }
    it { is_expected.to validate_inclusion_of(:status).in_array(LlmInteraction::STATUSES) }
  end

  describe "#mark_completed!" do
    it "sets status and response" do
      interaction = create(:llm_interaction)
      interaction.mark_completed!("result text", { "total_tokens" => 100 }, 500)
      expect(interaction.status).to eq("completed")
      expect(interaction.response).to eq("result text")
      expect(interaction.token_usage["total_tokens"]).to eq(100)
      expect(interaction.latency_ms).to eq(500)
    end
  end

  describe "#mark_failed!" do
    it "sets status to failed with error" do
      interaction = create(:llm_interaction)
      interaction.mark_failed!("API error")
      expect(interaction.status).to eq("failed")
      expect(interaction.response).to eq("API error")
    end
  end

  describe "scopes" do
    it ".by_feature filters by feature_name" do
      create(:llm_interaction, feature_name: "resume_parse")
      create(:llm_interaction, feature_name: "cover_letter")
      expect(LlmInteraction.by_feature("resume_parse").count).to eq(1)
    end
  end
end
