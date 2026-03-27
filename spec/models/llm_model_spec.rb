require "rails_helper"

RSpec.describe LlmModel, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:llm_provider) }
    it { is_expected.to have_many(:llm_interactions).dependent(:nullify) }
  end

  describe "validations" do
    subject { build(:llm_model) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:identifier) }
    it { is_expected.to validate_uniqueness_of(:identifier).scoped_to(:llm_provider_id) }
  end

  describe "scopes" do
    let(:provider) { create(:llm_provider) }

    it ".text_capable returns text models" do
      text = create(:llm_model, llm_provider: provider, supports_text: true)
      create(:llm_model, llm_provider: provider, supports_text: false)
      expect(LlmModel.text_capable).to include(text)
    end

    it ".vision_capable returns vision models" do
      vision = create(:llm_model, :vision, llm_provider: provider)
      create(:llm_model, llm_provider: provider, supports_vision: false)
      expect(LlmModel.vision_capable).to include(vision)
    end
  end
end
