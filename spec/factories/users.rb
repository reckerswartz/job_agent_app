FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { "password123" }
    password_confirmation { "password123" }
    role { :user }
    onboarding_completed { true }

    trait :admin do
      role { :admin }
    end

    trait :not_onboarded do
      onboarding_completed { false }
    end
  end
end
