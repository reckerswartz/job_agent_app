require "rails_helper"

RSpec.describe LlmProvider, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:llm_models).dependent(:destroy) }
    it { is_expected.to have_many(:llm_interactions).dependent(:nullify) }
  end

  describe "validations" do
    subject { build(:llm_provider) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:slug) }
    it { is_expected.to validate_uniqueness_of(:slug) }
    it { is_expected.to validate_presence_of(:adapter) }
    it { is_expected.to validate_inclusion_of(:adapter).in_array(LlmProvider::ADAPTERS) }
    it { is_expected.to validate_presence_of(:base_url) }
  end

  describe "#api_key" do
    it "reads from AppSetting" do
      provider = build(:llm_provider, api_key_setting: "openai_api_key")
      allow(AppSetting).to receive(:get).with("openai_api_key").and_return("sk-test-key")
      expect(provider.api_key).to eq("sk-test-key")
    end

    it "returns nil when no setting configured" do
      provider = build(:llm_provider, api_key_setting: nil)
      expect(provider.api_key).to be_nil
    end
  end

  describe "#available?" do
    it "returns true when active and api_key present" do
      provider = build(:llm_provider, active: true, api_key_setting: "openai_api_key")
      allow(AppSetting).to receive(:get).with("openai_api_key").and_return("sk-test")
      expect(provider).to be_available
    end

    it "returns false when inactive" do
      provider = build(:llm_provider, :inactive)
      expect(provider).not_to be_available
    end
  end

  describe "#default_text_model" do
    it "returns the first active text model" do
      provider = create(:llm_provider)
      model = create(:llm_model, llm_provider: provider, supports_text: true)
      expect(provider.default_text_model).to eq(model)
    end
  end
end
