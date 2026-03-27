FactoryBot.define do
  factory :application_step do
    job_application
    sequence(:step_number) { |n| n }
    action { "fill_form" }
    status { "pending" }

    trait :completed do
      status { "completed" }
      started_at { 5.seconds.ago }
      finished_at { Time.current }
    end

    trait :failed do
      status { "failed" }
      started_at { 5.seconds.ago }
      finished_at { Time.current }
      error_message { "Element not found" }
    end

    trait :navigate do
      action { "navigate" }
    end

    trait :screenshot do
      action { "screenshot" }
    end
  end
end
