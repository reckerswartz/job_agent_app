class NegotiationAdvisor
  PROMPT = <<~PROMPT
    Based on the job listing and candidate profile, provide salary negotiation advice.
    Return ONLY valid JSON, no markdown or explanations.

    {
      "suggested_range": "$X - $Y (or equivalent currency)",
      "talking_points": ["point1", "point2", "point3"],
      "market_context": "Brief market analysis for this role/location",
      "negotiation_tips": ["tip1", "tip2"]
    }
  PROMPT

  def initialize(listing, profile)
    @listing = listing
    @profile = profile
  end

  def advise
    client = Llm::Client.for_feature("negotiation")
    return nil unless client

    messages = [
      { role: "system", content: "You are a compensation negotiation expert. Return only valid JSON." },
      { role: "user", content: build_prompt }
    ]

    result = client.chat(messages, user: @profile.user, profile: @profile, feature: "negotiation")
    json_text = result[:content].to_s.strip.gsub(/\A```json?\n?/, "").gsub(/\n?```\z/, "")
    parsed = JSON.parse(json_text)

    store_advice(parsed)
    parsed
  rescue JSON::ParserError => e
    Rails.logger.error("[NegotiationAdvisor] JSON parse failed: #{e.message}")
    nil
  rescue => e
    Rails.logger.error("[NegotiationAdvisor] Failed: #{e.message}")
    nil
  end

  private

  def build_prompt
    skills = @profile.profile_sections.find_by(section_type: "skills")
                     &.profile_entries&.map { |e| e.content["name"] }&.compact || []
    experience = @profile.profile_sections.find_by(section_type: "work_experience")
                         &.profile_entries&.count || 0

    salary_info = if @listing.salary_min.present?
      "Listed: #{@listing.salary_currency} #{@listing.salary_min} - #{@listing.salary_max} /#{@listing.salary_period}"
    elsif @listing.salary_range.present?
      "Listed: #{@listing.salary_range}"
    else
      "Not disclosed"
    end

    "#{PROMPT}\n\nJOB:\nTitle: #{@listing.title}\nCompany: #{@listing.company}\nLocation: #{@listing.location}\nSalary: #{salary_info}\n\nCANDIDATE:\nHeadline: #{@profile.headline}\nSkills: #{skills.join(', ')}\nExperience entries: #{experience}\nCity: #{@profile.contact_field('city')}"
  end

  def store_advice(parsed)
    existing = @listing.match_breakdown || {}
    existing["negotiation_advice"] = parsed.merge("advised_at" => Time.current.iso8601)
    @listing.update_column(:match_breakdown, existing)
  end
end
