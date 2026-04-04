FactoryBot.define do
  factory :webhook_endpoint do
    user
    url { "https://example.com/webhooks" }
    events { [ "scan.completed" ] }
    active { true }
  end
end
