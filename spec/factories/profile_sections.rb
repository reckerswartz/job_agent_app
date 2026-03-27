FactoryBot.define do
  factory :profile_section do
    profile
    section_type { "work_experience" }
    title { "" }

    trait :work_experience do
      section_type { "work_experience" }
    end

    trait :education do
      section_type { "education" }
    end

    trait :skills do
      section_type { "skills" }
    end

    trait :certifications do
      section_type { "certifications" }
    end

    trait :projects do
      section_type { "projects" }
    end

    trait :languages do
      section_type { "languages" }
    end
  end
end
