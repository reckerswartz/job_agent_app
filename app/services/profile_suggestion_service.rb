class ProfileSuggestionService
  PROMPT = <<~PROMPT
    Based on the following resume text, generate a professional profile.
    Return ONLY valid JSON, no markdown or explanations.

    {
      "headline": "A professional headline, 10 words max",
      "summary": "A 2-3 sentence professional summary highlighting key strengths and experience"
    }
  PROMPT

  def initialize(profile)
    @profile = profile
  end

  def suggest
    return nil if profile.source_text.blank?

    client = Llm::Client.for_feature("profile_suggestion")
    return nil unless client

    messages = [
      { role: "system", content: "You are a career coach. Return only valid JSON." },
      { role: "user", content: "#{PROMPT}\n\nResume text:\n#{profile.source_text.truncate(3000)}" }
    ]

    result = client.chat(messages, user: profile.user, profile: profile, feature: "profile_suggestion")
    json_text = result[:content].to_s.strip.gsub(/\A```json?\n?/, "").gsub(/\n?```\z/, "")
    JSON.parse(json_text)
  rescue JSON::ParserError => e
    Rails.logger.error("[ProfileSuggestionService] JSON parse failed: #{e.message}")
    nil
  rescue => e
    Rails.logger.error("[ProfileSuggestionService] Failed: #{e.message}")
    nil
  end

  private

  attr_reader :profile
end
