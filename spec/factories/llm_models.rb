FactoryBot.define do
  factory :llm_model do
    llm_provider
    name { "Nemotron Super 49B" }
    sequence(:identifier) { |n| "nvidia/nemotron-#{n}" }
    supports_text { true }
    supports_vision { false }
    model_type { "text" }
    active { true }

    trait :vision do
      name { "Llama Vision 72B" }
      supports_vision { true }
      model_type { "multimodal" }
    end

    trait :primary_text do
      role { "primary_text" }
    end

    trait :primary_vision do
      role { "primary_vision" }
      supports_vision { true }
      model_type { "multimodal" }
    end

    trait :verification do
      role { "verification" }
      name { "DeepSeek R1" }
    end

    trait :inactive do
      active { false }
    end
  end
end
