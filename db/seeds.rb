# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "=== Seeding Job Agent App ==="

# ── Users ──
admin = User.find_or_create_by!(email: "admin@jobagent.dev") do |u|
  u.password = "password123"
  u.password_confirmation = "password123"
  u.role = :admin
  u.onboarding_completed = true
end
admin.update!(onboarding_completed: true) unless admin.onboarding_completed?
puts "  Admin user: #{admin.email}"

demo = User.find_or_create_by!(email: "demo@jobagent.dev") do |u|
  u.password = "password123"
  u.password_confirmation = "password123"
  u.role = :user
  u.onboarding_completed = true
end
demo.update!(onboarding_completed: true) unless demo.onboarding_completed?
puts "  Demo user: #{demo.email}"

# ── Profile for demo user ──
profile = demo.profiles.first_or_create!(title: "My Resume") do |p|
  p.headline = "Senior Ruby on Rails Developer"
  p.summary = "Experienced Ruby on Rails developer with 8+ years building scalable web applications. Proficient in Ruby, Rails, PostgreSQL, Redis, and modern frontend technologies."
  p.contact_details = {
    "first_name" => "Pankaj",
    "surname" => "Kumar",
    "email" => "pankaj@example.com",
    "phone" => "+91-9876543210",
    "city" => "New Delhi",
    "country" => "India",
    "linkedin" => "https://linkedin.com/in/pankajkumar",
    "website" => "https://pankajkumar.dev"
  }
  p.personal_details = {
    "nationality" => "Indian"
  }
end
puts "  Profile: #{profile.title} (#{profile.display_name})"

# Attach sample resume PDF if not already attached
resume_path = Rails.root.join("public/sample_resume_to_test/pankaj_senior_ruby_on_rails_developer_8_converted.pdf")
if resume_path.exist? && !profile.source_document.attached?
  profile.source_document.attach(
    io: File.open(resume_path),
    filename: "pankaj_resume.pdf",
    content_type: "application/pdf"
  )
  profile.update!(source_mode: "upload")

  # Run the parser synchronously
  extracted = ResumeParser::Orchestrator.new(profile).call
  if extracted.present?
    puts "  Resume PDF attached and parsed (#{extracted.length} chars extracted)"
  else
    puts "  Resume PDF attached (parsing returned no text)"
  end
end

# ── Profile Sections & Entries ──
# Work Experience
work = profile.profile_sections.find_or_create_by!(section_type: "work_experience") do |s|
  s.title = "Work Experience"
end
if work.profile_entries.empty?
  work.profile_entries.create!(content: {
    "title" => "Senior Ruby on Rails Developer",
    "company" => "TechCorp Solutions",
    "location" => "New Delhi, India",
    "start_date" => "Jan 2020",
    "end_date" => "Present",
    "current" => "true",
    "description" => "Led development of microservices architecture serving 1M+ daily users. Implemented CI/CD pipelines reducing deployment time by 60%."
  })
  work.profile_entries.create!(content: {
    "title" => "Ruby on Rails Developer",
    "company" => "WebStudio Inc",
    "location" => "Bangalore, India",
    "start_date" => "Jun 2016",
    "end_date" => "Dec 2019",
    "current" => "false",
    "description" => "Built e-commerce platform processing $2M+ monthly transactions. Optimized database queries reducing response times by 40%."
  })
  puts "  Work Experience: 2 entries"
end

# Education
edu = profile.profile_sections.find_or_create_by!(section_type: "education") do |s|
  s.title = "Education"
end
if edu.profile_entries.empty?
  edu.profile_entries.create!(content: {
    "institution" => "Delhi University",
    "degree" => "Bachelor of Technology",
    "field" => "Computer Science",
    "start_date" => "2012",
    "end_date" => "2016"
  })
  puts "  Education: 1 entry"
end

# Skills
skills = profile.profile_sections.find_or_create_by!(section_type: "skills") do |s|
  s.title = "Skills"
end
if skills.profile_entries.empty?
  %w[Ruby Rails PostgreSQL Redis Sidekiq RSpec JavaScript React Docker AWS].each do |skill|
    level = %w[Expert Advanced Advanced Intermediate Advanced Advanced Intermediate Intermediate Intermediate Advanced]
    skills.profile_entries.create!(content: {
      "name" => skill,
      "level" => level[%w[Ruby Rails PostgreSQL Redis Sidekiq RSpec JavaScript React Docker AWS].index(skill)] || "Intermediate",
      "category" => skill.in?(%w[Ruby Rails]) ? "Backend" : (skill.in?(%w[JavaScript React]) ? "Frontend" : "DevOps/Tools")
    })
  end
  puts "  Skills: 10 entries"
end

# Certifications
certs = profile.profile_sections.find_or_create_by!(section_type: "certifications") do |s|
  s.title = "Certifications"
end
if certs.profile_entries.empty?
  certs.profile_entries.create!(content: {
    "name" => "AWS Certified Developer Associate",
    "issuer" => "Amazon Web Services",
    "date" => "2022"
  })
  puts "  Certifications: 1 entry"
end

profile.update!(status: "complete")

# ── LLM Providers & Models (NVIDIA Build API) ──
nvidia = LlmProvider.find_or_create_by!(slug: "nvidia") do |p|
  p.name = "NVIDIA Build"
  p.adapter = "nvidia"
  p.base_url = "https://integrate.api.nvidia.com/v1"
  p.api_key_setting = "nvidia_api_key"
end

# Vision/Multimodal models
LlmModel.find_or_create_by!(llm_provider: nvidia, identifier: "nvidia/llama-3.2-nv-vision-72b-preview") do |m|
  m.name = "Llama 3.2 NV Vision 72B"
  m.supports_text = true
  m.supports_vision = true
  m.model_type = "multimodal"
  m.role = "primary_vision"
  m.context_window = 128_000
end
LlmModel.find_or_create_by!(llm_provider: nvidia, identifier: "meta/llama-4-maverick-17b-128e-instruct") do |m|
  m.name = "Llama 4 Maverick 17B"
  m.supports_text = true
  m.supports_vision = true
  m.model_type = "multimodal"
  m.context_window = 128_000
end

# Text models
LlmModel.find_or_create_by!(llm_provider: nvidia, identifier: "nvidia/llama-3.3-nemotron-super-49b-v1") do |m|
  m.name = "Llama 3.3 Nemotron Super 49B"
  m.supports_text = true
  m.supports_vision = false
  m.model_type = "text"
  m.role = "primary_text"
  m.context_window = 32_000
end
LlmModel.find_or_create_by!(llm_provider: nvidia, identifier: "meta/llama-3.1-70b-instruct") do |m|
  m.name = "Llama 3.1 70B Instruct"
  m.supports_text = true
  m.supports_vision = false
  m.model_type = "text"
  m.context_window = 128_000
end
LlmModel.find_or_create_by!(llm_provider: nvidia, identifier: "deepseek-ai/deepseek-r1") do |m|
  m.name = "DeepSeek R1"
  m.supports_text = true
  m.supports_vision = false
  m.model_type = "text"
  m.role = "verification"
  m.context_window = 64_000
end
puts "  NVIDIA Build: #{nvidia.llm_models.count} models"

puts ""
puts "=== Seed Complete ==="
puts "  Users: #{User.count}"
puts "  Profiles: #{Profile.count}"
puts "  Sections: #{ProfileSection.count}"
puts "  Entries: #{ProfileEntry.count}"
puts "  LLM Providers: #{LlmProvider.count}"
puts "  LLM Models: #{LlmModel.count}"
puts ""
puts "  Sign in as: demo@jobagent.dev / password123"
puts "  Admin:      admin@jobagent.dev / password123"
