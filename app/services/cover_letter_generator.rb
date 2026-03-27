class CoverLetterGenerator
  PROMPT = <<~PROMPT
    Write a professional cover letter for the following job application.
    Use the candidate's profile information to tailor the letter.
    Keep it concise (3-4 paragraphs), professional, and focused on why the candidate is a good fit.
    Do not include placeholder text — write a complete, ready-to-send letter.

    Job Title: %{title}
    Company: %{company}
    Job Description: %{description}

    Candidate Name: %{name}
    Candidate Headline: %{headline}
    Candidate Summary: %{summary}
    Key Skills: %{skills}
  PROMPT

  def initialize(job_listing, profile)
    @listing = job_listing
    @profile = profile
  end

  def call
    client = Llm::Client.for_feature("cover_letter")
    return nil unless client

    prompt_text = format(PROMPT,
      title: listing.title,
      company: listing.company,
      description: listing.description.to_s.truncate(2000),
      name: profile.display_name,
      headline: profile.headline,
      summary: profile.summary.to_s.truncate(500),
      skills: skill_names.join(", ")
    )

    messages = [
      { role: "system", content: "You are an expert career coach who writes compelling cover letters." },
      { role: "user", content: prompt_text }
    ]

    result = client.chat(messages, user: profile.user, profile: profile, feature: "cover_letter")
    result[:content]
  rescue => e
    Rails.logger.error("[CoverLetterGenerator] Failed: #{e.message}")
    nil
  end

  private

  attr_reader :listing, :profile

  def skill_names
    skills_section = profile.profile_sections.find_by(section_type: "skills")
    return [] unless skills_section

    skills_section.profile_entries.map { |e| e.content["name"] }.compact
  end
end
