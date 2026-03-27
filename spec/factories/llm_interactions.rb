FactoryBot.define do
  factory :llm_interaction do
    user
    feature_name { "resume_parse" }
    status { "pending" }
    prompt { "Extract text from this resume" }

    trait :completed do
      status { "completed" }
      response { "Extracted text content" }
      token_usage { { "prompt_tokens" => 100, "completion_tokens" => 200, "total_tokens" => 300 } }
      latency_ms { 1500 }
    end

    trait :failed do
      status { "failed" }
      response { "API error: rate limit exceeded" }
    end
  end
end
