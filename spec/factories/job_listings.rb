FactoryBot.define do
  factory :job_listing do
    job_source
    title { Faker::Job.title }
    company { Faker::Company.name }
    location { "#{Faker::Address.city}, #{Faker::Address.country}" }
    url { Faker::Internet.url }
    external_id { SecureRandom.hex(8) }
    status { "new" }
    posted_at { rand(1..14).days.ago }

    trait :high_match do
      match_score { rand(70..95) }
    end

    trait :medium_match do
      match_score { rand(40..69) }
    end

    trait :low_match do
      match_score { rand(10..39) }
    end

    trait :saved do
      status { "saved" }
    end

    trait :applied do
      status { "applied" }
    end

    trait :rejected do
      status { "rejected" }
    end
  end
end
