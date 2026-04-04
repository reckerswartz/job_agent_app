FactoryBot.define do
  factory :job_listing_note do
    job_listing
    user
    content { "This looks like a great opportunity. The tech stack matches well." }
  end
end
