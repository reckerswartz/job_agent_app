FactoryBot.define do
  factory :profile_entry do
    profile_section

    content do
      case profile_section&.section_type
      when "work_experience"
        {
          "title" => Faker::Job.title,
          "company" => Faker::Company.name,
          "location" => "#{Faker::Address.city}, #{Faker::Address.country}",
          "start_date" => "Jan 2020",
          "end_date" => "Present",
          "current" => "true",
          "description" => Faker::Lorem.paragraph(sentence_count: 2)
        }
      when "education"
        {
          "institution" => "#{Faker::University.name}",
          "degree" => "Bachelor of Technology",
          "field" => "Computer Science",
          "start_date" => "2012",
          "end_date" => "2016"
        }
      when "skills"
        {
          "name" => Faker::ProgrammingLanguage.name,
          "level" => %w[Beginner Intermediate Advanced Expert].sample,
          "category" => "Programming"
        }
      when "certifications"
        {
          "name" => "AWS Certified Developer",
          "issuer" => "Amazon Web Services",
          "date" => "2022"
        }
      when "projects"
        {
          "name" => Faker::App.name,
          "url" => Faker::Internet.url,
          "description" => Faker::Lorem.sentence
        }
      when "languages"
        {
          "name" => Faker::Nation.language,
          "proficiency" => %w[Native Fluent Advanced Intermediate Basic].sample
        }
      else
        { "title" => Faker::Lorem.word }
      end
    end
  end
end
