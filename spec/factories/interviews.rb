FactoryBot.define do
  factory :interview do
    job_application
    stage { "technical" }
    status { "scheduled" }
    scheduled_at { 3.days.from_now }

    trait :completed do
      status { "completed" }
      scheduled_at { 2.days.ago }
      rating { 4 }
    end

    trait :cancelled do
      status { "cancelled" }
    end

    trait :with_prep do
      prep_questions { '["Tell me about yourself", "Describe a challenging project"]' }
    end
  end
end
