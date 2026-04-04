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

# ══════════════════════════════════════════════════════════════════════════════
# Demo Data: Job Sources, Listings, Applications, Activity, Notifications, etc.
# ══════════════════════════════════════════════════════════════════════════════

# ── Job Search Criteria ──
criteria_rails = demo.job_search_criteria.find_or_create_by!(name: "Senior Rails Developer") do |c|
  c.keywords = "Ruby on Rails, Senior, Backend"
  c.location = "Remote"
  c.remote_preference = "remote"
  c.job_type = "full_time"
  c.experience_level = "senior"
  c.salary_min = 120_000
  c.salary_max = 200_000
  c.is_default = true
end

criteria_fs = demo.job_search_criteria.find_or_create_by!(name: "Full Stack Engineer") do |c|
  c.keywords = "Full Stack, React, Rails"
  c.location = "New Delhi, India"
  c.remote_preference = "hybrid"
  c.job_type = "full_time"
  c.experience_level = "senior"
  c.salary_min = 80_000
  c.salary_max = 150_000
  c.is_default = false
end
puts "  Search Criteria: #{demo.job_search_criteria.count}"

# ── Job Sources ──
src_linkedin = demo.job_sources.find_or_create_by!(name: "My LinkedIn") do |s|
  s.platform = "linkedin"
  s.scan_interval_hours = 6
  s.enabled = true
  s.status = "active"
  s.last_scanned_at = 2.hours.ago
end

src_indeed = demo.job_sources.find_or_create_by!(name: "Indeed Search") do |s|
  s.platform = "indeed"
  s.scan_interval_hours = 12
  s.enabled = true
  s.status = "active"
  s.last_scanned_at = 5.hours.ago
end

src_naukri = demo.job_sources.find_or_create_by!(name: "Naukri Premium") do |s|
  s.platform = "naukri"
  s.scan_interval_hours = 8
  s.enabled = true
  s.status = "active"
  s.last_scanned_at = 1.day.ago
end
puts "  Job Sources: #{demo.job_sources.count}"

# ── Scan Runs ──
if JobScanRun.where(job_source: demo.job_sources).empty?
  [
    { source: src_linkedin, status: "completed", started: 2.hours.ago, finished: 110.minutes.ago, found: 18, new_l: 12, dur: 600_000 },
    { source: src_indeed,   status: "completed", started: 5.hours.ago, finished: 285.minutes.ago, found: 10, new_l: 6,  dur: 420_000 },
    { source: src_naukri,   status: "completed", started: 1.day.ago,   finished: 23.hours.ago,    found: 8,  new_l: 5,  dur: 350_000 },
    { source: src_linkedin, status: "failed",    started: 1.day.ago,   finished: 23.5.hours.ago,  found: 0,  new_l: 0,  dur: 293_000 }
  ].each do |r|
    JobScanRun.create!(
      job_source: r[:source], job_search_criteria: criteria_rails,
      status: r[:status], started_at: r[:started], finished_at: r[:finished],
      listings_found: r[:found], new_listings: r[:new_l], duration_ms: r[:dur],
      error_details: r[:status] == "failed" ? { "message" => "Login session expired", "class" => "BrowserSession::SessionError" } : {}
    )
  end
  puts "  Scan Runs: #{JobScanRun.where(job_source: demo.job_sources).count}"
end

# ── Job Listings ──
if JobListing.for_user(demo).empty?
  listings_data = [
    { title: "Senior Ruby on Rails Developer",       company: "Shopify",         location: "Remote",              remote: "remote",  type: "full_time", match: 92, salary_min: 160_000, salary_max: 200_000, easy: true,  source: src_linkedin, status: "new",      posted: 1.day.ago },
    { title: "Staff Backend Engineer (Rails)",       company: "GitHub",          location: "Remote, US",          remote: "remote",  type: "full_time", match: 88, salary_min: 180_000, salary_max: 230_000, easy: false, source: src_linkedin, status: "reviewed", posted: 2.days.ago },
    { title: "Senior Full Stack Developer",          company: "Basecamp",        location: "Remote",              remote: "remote",  type: "full_time", match: 85, salary_min: 150_000, salary_max: 190_000, easy: true,  source: src_linkedin, status: "applied",  posted: 3.days.ago },
    { title: "Rails Tech Lead",                      company: "Stripe",          location: "San Francisco, CA",   remote: "hybrid",  type: "full_time", match: 82, salary_min: 190_000, salary_max: 250_000, easy: false, source: src_indeed,   status: "applied",  posted: 4.days.ago },
    { title: "Senior Backend Developer",             company: "Gusto",           location: "Remote, US",          remote: "remote",  type: "full_time", match: 78, salary_min: 145_000, salary_max: 185_000, easy: true,  source: src_linkedin, status: "applied",  posted: 5.days.ago },
    { title: "Senior Software Engineer",             company: "Instacart",       location: "Remote",              remote: "remote",  type: "full_time", match: 75, salary_min: 155_000, salary_max: 195_000, easy: true,  source: src_indeed,   status: "applied",  posted: 5.days.ago },
    { title: "Ruby Developer",                       company: "Cookpad",         location: "Bristol, UK",         remote: "hybrid",  type: "full_time", match: 72, salary_min: 80_000,  salary_max: 110_000, easy: false, source: src_linkedin, status: "saved",    posted: 6.days.ago },
    { title: "Full Stack Engineer",                  company: "Zendesk",         location: "Remote, India",       remote: "remote",  type: "full_time", match: 68, salary_min: 60_000,  salary_max: 90_000,  easy: true,  source: src_naukri,   status: "applied",  posted: 7.days.ago },
    { title: "Senior Platform Engineer",             company: "Heroku",          location: "Remote",              remote: "remote",  type: "full_time", match: 65, salary_min: 140_000, salary_max: 175_000, easy: false, source: src_indeed,   status: "new",      posted: 3.days.ago },
    { title: "Backend Engineer",                     company: "Flipkart",        location: "Bangalore, India",    remote: "onsite",  type: "full_time", match: 60, salary_min: 45_000,  salary_max: 70_000,  easy: true,  source: src_naukri,   status: "reviewed", posted: 8.days.ago },
    { title: "Rails API Developer",                  company: "Freshworks",      location: "Chennai, India",      remote: "hybrid",  type: "full_time", match: 55, salary_min: 40_000,  salary_max: 65_000,  easy: true,  source: src_naukri,   status: "new",      posted: 4.days.ago },
    { title: "Junior Ruby Developer",                company: "ThoughtBot",      location: "Remote",              remote: "remote",  type: "full_time", match: 42, salary_min: 90_000,  salary_max: 120_000, easy: true,  source: src_linkedin, status: "rejected", posted: 10.days.ago },
    { title: "DevOps Engineer (Ruby experience)",    company: "GitLab",          location: "Remote",              remote: "remote",  type: "full_time", match: 38, salary_min: 130_000, salary_max: 170_000, easy: false, source: src_indeed,   status: "new",      posted: 2.days.ago },
    { title: "Part-Time Rails Consultant",           company: "Toptal",          location: "Remote",              remote: "remote",  type: "contract",  match: 70, salary_min: 80_000,  salary_max: 120_000, easy: false, source: src_linkedin, status: "saved",    posted: 6.days.ago },
    { title: "Senior Software Engineer - Payments",  company: "Razorpay",        location: "Bangalore, India",    remote: "hybrid",  type: "full_time", match: 73, salary_min: 55_000,  salary_max: 85_000,  easy: true,  source: src_naukri,   status: "new",      posted: 1.day.ago },
    { title: "Principal Engineer (Ruby/Go)",         company: "Coinbase",        location: "Remote, US",          remote: "remote",  type: "full_time", match: 58, salary_min: 200_000, salary_max: 280_000, easy: false, source: src_linkedin, status: "new",      posted: 2.days.ago },
    { title: "Software Engineer II",                 company: "Twilio",          location: "Remote",              remote: "remote",  type: "full_time", match: 63, salary_min: 120_000, salary_max: 160_000, easy: true,  source: src_indeed,   status: "expired",  posted: 15.days.ago },
    { title: "Senior Rails Developer",               company: "Intercom",        location: "Dublin, Ireland",     remote: "hybrid",  type: "full_time", match: 80, salary_min: 100_000, salary_max: 140_000, easy: true,  source: src_linkedin, status: "applied",  posted: 8.days.ago }
  ]

  listings_data.each do |d|
    JobListing.create!(
      job_source: d[:source], title: d[:title], company: d[:company], location: d[:location],
      remote_type: d[:remote], employment_type: d[:type], match_score: d[:match],
      salary_min: d[:salary_min], salary_max: d[:salary_max], salary_currency: "USD", salary_period: "yearly",
      easy_apply: d[:easy], status: d[:status], posted_at: d[:posted],
      url: "https://example.com/jobs/#{d[:title].parameterize}",
      external_id: SecureRandom.hex(8),
      description: "We are looking for a #{d[:title]} to join #{d[:company]}. This is an exciting opportunity to work with cutting-edge technology.",
      requirements: "5+ years of experience with Ruby on Rails. Strong understanding of relational databases. Experience with REST APIs and background processing."
    )
  end
  puts "  Job Listings: #{JobListing.for_user(demo).count}"
end

# ── Job Applications (across pipeline stages) ──
if JobApplication.for_user(demo).empty?
  applied_listings = JobListing.for_user(demo).where(status: "applied").to_a
  app_data = [
    { listing_idx: 0, status: "submitted", stage: "interviewing", applied: 3.days.ago },
    { listing_idx: 1, status: "submitted", stage: "screening",    applied: 4.days.ago },
    { listing_idx: 2, status: "submitted", stage: "offered",      applied: 5.days.ago },
    { listing_idx: 3, status: "submitted", stage: "applied",      applied: 5.days.ago },
    { listing_idx: 4, status: "submitted", stage: "interviewing", applied: 7.days.ago },
    { listing_idx: 5, status: "submitted", stage: "rejected",     applied: 8.days.ago }
  ]

  app_data.each do |ad|
    listing = applied_listings[ad[:listing_idx]]
    next unless listing

    JobApplication.create!(
      job_listing: listing, profile: profile,
      status: ad[:status], pipeline_stage: ad[:stage],
      applied_at: ad[:applied]
    )
  end
  puts "  Applications: #{JobApplication.for_user(demo).count}"

  # ── Interviews ──
  interviewing_apps = JobApplication.for_user(demo).where(pipeline_stage: "interviewing").to_a
  if interviewing_apps.any? && Interview.for_user(demo).empty?
    Interview.create!(
      job_application: interviewing_apps.first,
      stage: "technical", status: "scheduled", format: "video",
      scheduled_at: 2.days.from_now,
      interviewer_name: "Sarah Chen",
      notes: "System design round focusing on scalability"
    )
    Interview.create!(
      job_application: interviewing_apps.first,
      stage: "phone_screen", status: "completed", format: "phone",
      scheduled_at: 2.days.ago,
      interviewer_name: "Mike Johnson",
      rating: 4,
      notes: "Good culture fit discussion"
    )
    if interviewing_apps.size > 1
      Interview.create!(
        job_application: interviewing_apps.second,
        stage: "behavioral", status: "scheduled", format: "video",
        scheduled_at: 4.days.from_now,
        interviewer_name: "Lisa Park"
      )
    end
    puts "  Interviews: #{Interview.for_user(demo).count}"
  end
end

# ── Activity Logs ──
if demo.activity_logs.empty?
  [
    { action: "scan_completed",        category: "scan",        desc: "LinkedIn scan completed — 12 new listings found",               ago: 2.hours.ago },
    { action: "scan_completed",        category: "scan",        desc: "Indeed scan completed — 6 new listings found",                  ago: 5.hours.ago },
    { action: "scan_failed",           category: "scan",        desc: "LinkedIn scan failed — Login session expired",                  ago: 1.day.ago },
    { action: "application_submitted", category: "application", desc: "Applied to Senior Full Stack Developer at Basecamp",            ago: 3.days.ago },
    { action: "application_submitted", category: "application", desc: "Applied to Rails Tech Lead at Stripe",                         ago: 4.days.ago },
    { action: "application_submitted", category: "application", desc: "Applied to Senior Backend Developer at Gusto",                 ago: 5.days.ago },
    { action: "listing_saved",         category: "listing",     desc: "Saved Ruby Developer at Cookpad",                              ago: 6.days.ago },
    { action: "profile_updated",       category: "profile",     desc: "Updated contact details and work experience",                  ago: 7.days.ago },
    { action: "resume_uploaded",       category: "profile",     desc: "Uploaded and parsed resume PDF",                               ago: 7.days.ago },
    { action: "source_created",        category: "settings",    desc: "Added LinkedIn as a job source",                               ago: 8.days.ago },
    { action: "source_created",        category: "settings",    desc: "Added Indeed as a job source",                                 ago: 8.days.ago },
    { action: "settings_updated",      category: "settings",    desc: "Enabled auto-apply for Easy Apply listings (min match: 80%)",  ago: 8.days.ago },
    { action: "stage_updated",         category: "application", desc: "Moved Basecamp application to Interviewing stage",             ago: 2.days.ago },
    { action: "stage_updated",         category: "application", desc: "Moved Instacart application to Offered stage",                 ago: 1.day.ago }
  ].each do |log|
    demo.activity_logs.create!(
      action: log[:action], category: log[:category],
      description: log[:desc], created_at: log[:ago]
    )
  end
  puts "  Activity Logs: #{demo.activity_logs.count}"
end

# ── Notifications ──
if demo.notifications.empty?
  [
    { title: "Scan completed",            body: "LinkedIn scan found 12 new listings matching your criteria.",                    cat: "scan",         url: "/job_listings",                      read: nil,           ago: 2.hours.ago },
    { title: "New high match!",           body: "Senior Ruby on Rails Developer at Shopify — 92% match.",                        cat: "scan",         url: "/job_listings",                      read: nil,           ago: 2.hours.ago },
    { title: "Indeed scan completed",     body: "6 new listings found from Indeed.",                                             cat: "scan",         url: "/job_listings",                      read: nil,           ago: 5.hours.ago },
    { title: "Application submitted",     body: "Successfully applied to Senior Full Stack Developer at Basecamp.",              cat: "application",  url: "/job_applications",                  read: 3.days.ago,    ago: 3.days.ago },
    { title: "Interview scheduled",       body: "Technical interview with Basecamp scheduled for #{2.days.from_now.strftime('%b %d')}.",  cat: "application",  url: "/job_applications",     read: 2.days.ago,    ago: 2.days.ago },
    { title: "Scan failed",              body: "LinkedIn scan failed: login session expired. Please re-authenticate.",           cat: "intervention", url: "/interventions",                     read: nil,           ago: 1.day.ago },
    { title: "Offer received!",          body: "Instacart has moved your application to Offered stage.",                         cat: "application",  url: "/job_applications",                  read: nil,           ago: 1.day.ago },
    { title: "Naukri scan completed",    body: "Found 5 new listings from Naukri.",                                             cat: "scan",         url: "/job_listings",                      read: 1.day.ago,     ago: 1.day.ago }
  ].each do |n|
    demo.notifications.create!(
      title: n[:title], body: n[:body], category: n[:cat],
      action_url: n[:url], read_at: n[:read], created_at: n[:ago]
    )
  end
  puts "  Notifications: #{demo.notifications.count} (#{demo.notifications.unread.count} unread)"
end

# ── Interventions ──
if demo.interventions.empty?
  pending_source = src_linkedin
  Intervention.create!(
    user: demo, interventionable: pending_source,
    intervention_type: "login_required", status: "pending",
    context: { "message" => "LinkedIn session expired. Please sign in again to continue scanning.", "url" => "https://www.linkedin.com/login" }
  )

  resolved_app = JobApplication.for_user(demo).first
  if resolved_app
    Intervention.create!(
      user: demo, interventionable: resolved_app,
      intervention_type: "captcha", status: "resolved",
      context: { "message" => "CAPTCHA challenge encountered during application submission." },
      resolved_at: 3.days.ago,
      user_input: { "action" => "manually_solved" }
    )
  end

  dismissed_source = src_naukri
  Intervention.create!(
    user: demo, interventionable: dismissed_source,
    intervention_type: "verification", status: "dismissed",
    context: { "message" => "Phone verification required for Naukri account." },
    resolved_at: 5.days.ago
  )
  puts "  Interventions: #{demo.interventions.count} (#{demo.interventions.pending.count} pending)"
end

# ── Job Listing Notes ──
if demo.job_listing_notes.empty?
  listings_with_notes = JobListing.for_user(demo).where(status: %w[applied saved reviewed]).limit(5).to_a
  notes_data = [
    "Great tech stack — matches my experience with Rails + PostgreSQL perfectly.",
    "Salary range looks competitive. Should negotiate for the upper end based on 8 years experience.",
    "Company culture seems strong based on Glassdoor reviews. Worth preparing behavioral questions.",
    "Remote-first is a big plus. Check if they cover home office setup costs.",
    "Interviewer mentioned they use microservices — prepare examples from TechCorp project."
  ]
  listings_with_notes.each_with_index do |listing, i|
    demo.job_listing_notes.create!(
      job_listing: listing,
      content: notes_data[i] || "Interesting opportunity — follow up next week."
    )
  end
  puts "  Job Listing Notes: #{demo.job_listing_notes.count}"
end

# ── LLM Provider (NVIDIA Build API) ──
# Models are synced dynamically via Admin > LLM Models > Sync, or `rails llm:sync`
nvidia = LlmProvider.find_or_create_by!(slug: "nvidia") do |p|
  p.name = "NVIDIA Build"
  p.adapter = "nvidia"
  p.base_url = "https://integrate.api.nvidia.com/v1"
  p.api_key_setting = "nvidia_api_key"
end
puts "  NVIDIA provider: #{nvidia.name} (models: #{nvidia.llm_models.count} — run `rails llm:sync` to populate)"

puts ""
puts "=== Seed Complete ==="
puts "  Users: #{User.count}"
puts "  Profiles: #{Profile.count}"
puts "  Sections: #{ProfileSection.count}"
puts "  Entries: #{ProfileEntry.count}"
puts "  Job Sources: #{JobSource.count}"
puts "  Search Criteria: #{JobSearchCriteria.count}"
puts "  Scan Runs: #{JobScanRun.count}"
puts "  Job Listings: #{JobListing.count}"
puts "  Applications: #{JobApplication.count}"
puts "  Interviews: #{Interview.count}"
puts "  Activity Logs: #{ActivityLog.count}"
puts "  Notifications: #{Notification.count}"
puts "  Interventions: #{Intervention.count}"
puts "  LLM Providers: #{LlmProvider.count}"
puts "  LLM Models: #{LlmModel.count}"
puts ""
puts "  Sign in as: demo@jobagent.dev / password123"
puts "  Admin:      admin@jobagent.dev / password123"
