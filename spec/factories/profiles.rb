FactoryBot.define do
  factory :profile do
    user
    title { "My Resume" }
    headline { Faker::Job.title }
    summary { Faker::Lorem.paragraph(sentence_count: 3) }
    contact_details do
      {
        "first_name" => Faker::Name.first_name,
        "surname" => Faker::Name.last_name,
        "email" => Faker::Internet.email,
        "phone" => Faker::PhoneNumber.phone_number,
        "city" => Faker::Address.city,
        "country" => Faker::Address.country,
        "linkedin" => "https://linkedin.com/in/#{Faker::Internet.username}",
        "website" => Faker::Internet.url
      }
    end
    source_mode { "scratch" }
    status { "draft" }

    trait :complete do
      status { "complete" }
    end

    trait :with_upload do
      source_mode { "upload" }
      source_text { Faker::Lorem.paragraphs(number: 5).join("\n\n") }
    end
  end
end
