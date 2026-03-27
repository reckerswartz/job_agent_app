FactoryBot.define do
  factory :intervention do
    user
    association :interventionable, factory: :job_application
    intervention_type { "login_required" }
    status { "pending" }
    context { { "page_url" => "https://linkedin.com/login", "error" => "Login required" } }

    trait :login_required do
      intervention_type { "login_required" }
    end

    trait :captcha do
      intervention_type { "captcha" }
    end

    trait :account_creation do
      intervention_type { "account_creation" }
    end

    trait :unknown_field do
      intervention_type { "unknown_field" }
      context { { "field_name" => "cover_letter", "page_url" => "https://example.com/apply" } }
    end

    trait :verification do
      intervention_type { "verification" }
    end

    trait :resolved do
      status { "resolved" }
      resolved_at { Time.current }
      user_input { { "username" => "user@example.com" } }
    end

    trait :dismissed do
      status { "dismissed" }
      resolved_at { Time.current }
    end

    trait :for_scan_run do
      association :interventionable, factory: :job_scan_run
    end

    trait :for_job_source do
      association :interventionable, factory: :job_source
    end
  end
end
