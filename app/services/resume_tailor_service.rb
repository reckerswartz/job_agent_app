class ResumeTailorService
  PROMPT = <<~PROMPT
    You are a career coach. Given a candidate's profile and a target job listing,
    produce a tailored resume summary and highlight the most relevant skills.
    Return ONLY valid JSON, no markdown or explanations.

    {
      "tailored_summary": "2-3 sentence summary tailored to this specific job",
      "highlighted_skills": ["skill1", "skill2", "skill3"],
      "experience_highlights": ["relevant experience point 1", "relevant experience point 2"]
    }
  PROMPT

  def initialize(listing, profile)
    @listing = listing
    @profile = profile
  end

  def tailor
    client = Llm::Client.for_feature("resume_tailor")
    return nil unless client

    messages = [
      { role: "system", content: "You are an expert resume writer. Return only valid JSON." },
      { role: "user", content: build_prompt }
    ]

    result = client.chat(messages, user: profile.user, profile: profile, feature: "resume_tailor")
    json_text = result[:content].to_s.strip.gsub(/\A```json?\n?/, "").gsub(/\n?```\z/, "")
    parsed = JSON.parse(json_text)

    store_tailored_data(parsed)
    parsed
  rescue JSON::ParserError => e
    Rails.logger.error("[ResumeTailorService] JSON parse failed: #{e.message}")
    nil
  rescue => e
    Rails.logger.error("[ResumeTailorService] Failed: #{e.message}")
    nil
  end

  private

  attr_reader :listing, :profile

  def build_prompt
    skills = profile.profile_sections.find_by(section_type: "skills")
                    &.profile_entries&.map { |e| e.content["name"] }&.compact || []

    experience = profile.profile_sections.find_by(section_type: "work_experience")
                        &.profile_entries&.first(3)&.map { |e| "#{e.content['title']} at #{e.content['company']}" } || []

    "#{PROMPT}\n\nJOB:\nTitle: #{listing.title}\nCompany: #{listing.company}\nDescription: #{listing.description.to_s.truncate(1500)}\n\nPROFILE:\nHeadline: #{profile.headline}\nSummary: #{profile.summary.to_s.truncate(400)}\nSkills: #{skills.join(', ')}\nExperience: #{experience.join('; ')}"
  end

  def store_tailored_data(parsed)
    existing = listing.match_breakdown || {}
    existing["tailored_resume"] = parsed.merge("tailored_at" => Time.current.iso8601)
    listing.update_column(:match_breakdown, existing)
  end
end
