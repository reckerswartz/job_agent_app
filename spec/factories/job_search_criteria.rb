FactoryBot.define do
  factory :job_search_criteria, class: "JobSearchCriteria" do
    user
    name { "#{Faker::Job.title} Search" }
    keywords { Faker::Job.title }
    location { Faker::Address.city }
    remote_preference { "any" }
    job_type { "full_time" }
    is_default { false }

    trait :default do
      is_default { true }
    end

    trait :with_salary do
      salary_min { 50_000 }
      salary_max { 150_000 }
    end
  end
end
