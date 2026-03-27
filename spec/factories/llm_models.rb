FactoryBot.define do
  factory :llm_model do
    llm_provider
    name { "GPT-4o" }
    sequence(:identifier) { |n| "gpt-4o-#{n}" }
    supports_text { true }
    supports_vision { false }
    active { true }

    trait :vision do
      supports_vision { true }
    end

    trait :inactive do
      active { false }
    end
  end
end
