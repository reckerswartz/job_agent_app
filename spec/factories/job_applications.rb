FactoryBot.define do
  factory :job_application do
    job_listing
    profile
    status { "queued" }

    trait :in_progress do
      status { "in_progress" }
    end

    trait :submitted do
      status { "submitted" }
      applied_at { Time.current }
    end

    trait :failed do
      status { "failed" }
      error_details { { "message" => "Connection timeout", "class" => "Net::ReadTimeout" } }
    end

    trait :needs_intervention do
      status { "needs_intervention" }
      error_details { { "reason" => "Login required" } }
    end
  end
end
