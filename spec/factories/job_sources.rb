FactoryBot.define do
  factory :job_source do
    user
    name { "My LinkedIn" }
    platform { "linkedin" }
    enabled { true }
    scan_interval_hours { 6 }
    status { "active" }

    trait :linkedin do
      platform { "linkedin" }
    end

    trait :indeed do
      platform { "indeed" }
    end

    trait :naukri do
      platform { "naukri" }
    end

    trait :disabled do
      enabled { false }
    end

    trait :with_credentials do
      credentials { { "username" => Faker::Internet.email, "password" => "secret123" } }
    end
  end
end
