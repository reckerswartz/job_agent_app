FactoryBot.define do
  factory :job_scan_run do
    job_source
    status { "queued" }

    trait :running do
      status { "running" }
      started_at { Time.current }
    end

    trait :completed do
      status { "completed" }
      started_at { 5.minutes.ago }
      finished_at { Time.current }
      duration_ms { 300_000 }
      listings_found { 15 }
      new_listings { 8 }
    end

    trait :failed do
      status { "failed" }
      started_at { 1.minute.ago }
      finished_at { Time.current }
      error_details { { "message" => "Connection timeout", "class" => "Net::ReadTimeout" } }
    end
  end
end
