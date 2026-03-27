FactoryBot.define do
  factory :llm_provider do
    name { "NVIDIA Build" }
    sequence(:slug) { |n| "nvidia-#{n}" }
    adapter { "nvidia" }
    base_url { "https://integrate.api.nvidia.com/v1" }
    api_key_setting { "nvidia_api_key" }
    active { true }

    trait :inactive do
      active { false }
    end
  end
end
