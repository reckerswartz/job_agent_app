class InterviewPrepService
  PROMPT = <<~PROMPT
    Based on the job listing and candidate profile below, generate 8-10 likely interview questions.
    Include a mix of: technical questions (3-4), behavioral questions (3-4), and culture fit questions (2).
    Return ONLY a valid JSON array of strings, no markdown or explanations.

    Example: ["Tell me about your experience with...", "How would you handle..."]
  PROMPT

  def initialize(interview)
    @interview = interview
    @listing = interview.job_application.job_listing
    @profile = interview.job_application.profile
  end

  def generate_questions
    client = Llm::Client.for_feature("interview_prep")
    return nil unless client

    messages = [
      { role: "system", content: "You are an expert interview coach. Return only a valid JSON array of question strings." },
      { role: "user", content: build_prompt }
    ]

    result = client.chat(messages, user: @profile.user, profile: @profile, feature: "interview_prep")
    json_text = result[:content].to_s.strip.gsub(/\A```json?\n?/, "").gsub(/\n?```\z/, "")
    questions = JSON.parse(json_text)

    @interview.update!(prep_questions: questions.to_json)
    questions
  rescue JSON::ParserError => e
    Rails.logger.error("[InterviewPrepService] JSON parse failed: #{e.message}")
    nil
  rescue => e
    Rails.logger.error("[InterviewPrepService] Failed: #{e.message}")
    nil
  end

  private

  def build_prompt
    skills = @profile.profile_sections.find_by(section_type: "skills")
                     &.profile_entries&.map { |e| e.content["name"] }&.compact || []

    "#{PROMPT}\n\nJOB:\nTitle: #{@listing.title}\nCompany: #{@listing.company}\nDescription: #{@listing.description.to_s.truncate(2000)}\n\nCANDIDATE:\nHeadline: #{@profile.headline}\nSkills: #{skills.join(', ')}\n\nINTERVIEW STAGE: #{@interview.stage_label}"
  end
end
