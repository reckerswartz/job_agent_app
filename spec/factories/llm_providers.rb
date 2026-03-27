FactoryBot.define do
  factory :llm_provider do
    name { "OpenAI" }
    sequence(:slug) { |n| "openai-#{n}" }
    adapter { "openai" }
    base_url { "https://api.openai.com/v1" }
    api_key_setting { "openai_api_key" }
    active { true }

    trait :anthropic do
      name { "Anthropic" }
      sequence(:slug) { |n| "anthropic-#{n}" }
      adapter { "anthropic" }
      base_url { "https://api.anthropic.com/v1" }
      api_key_setting { "anthropic_api_key" }
    end

    trait :inactive do
      active { false }
    end
  end
end
