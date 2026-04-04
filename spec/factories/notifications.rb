FactoryBot.define do
  factory :notification do
    user
    title { "Test notification" }
    body { "This is a test notification body." }
    category { "system" }
    action_url { "/dashboard" }
    read_at { nil }

    trait :read do
      read_at { 1.hour.ago }
    end

    trait :scan do
      category { "scan" }
      title { "Scan completed" }
      body { "LinkedIn scan found 5 new listings." }
      action_url { "/job_listings" }
    end

    trait :application do
      category { "application" }
      title { "Application submitted" }
      body { "Successfully applied to Senior Developer at Acme." }
      action_url { "/job_applications" }
    end
  end
end
