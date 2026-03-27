module ResumeParser
  class TextStructurer
    PROMPT = <<~PROMPT
      Analyze the following resume text and extract structured data as JSON.
      Return a JSON object with these keys:
      {
        "contact": { "first_name": "", "surname": "", "email": "", "phone": "", "city": "", "country": "", "linkedin": "", "website": "" },
        "headline": "",
        "summary": "",
        "work_experience": [{ "title": "", "company": "", "location": "", "start_date": "", "end_date": "", "current": false, "description": "" }],
        "education": [{ "institution": "", "degree": "", "field": "", "start_date": "", "end_date": "" }],
        "skills": [{ "name": "", "level": "", "category": "" }],
        "certifications": [{ "name": "", "issuer": "", "date": "" }],
        "languages": [{ "name": "", "proficiency": "" }]
      }
      Only include sections that have data. Return valid JSON only, no markdown or explanations.

      Resume text:
    PROMPT

    def initialize(profile)
      @profile = profile
    end

    def call
      return nil if profile.source_text.blank?

      client = Llm::Client.for_feature("resume_structure")
      return nil unless client

      messages = [
        { role: "system", content: "You are a resume parser. Return only valid JSON." },
        { role: "user", content: "#{PROMPT}\n#{profile.source_text}" }
      ]

      result = client.chat(messages, user: profile.user, profile: profile, feature: "resume_structure")
      json_text = result[:content].to_s.strip

      # Try to extract JSON from response (handle markdown code blocks)
      json_text = json_text.gsub(/\A```json?\n?/, "").gsub(/\n?```\z/, "")

      parsed = JSON.parse(json_text)
      apply_structured_data(parsed)
      parsed
    rescue JSON::ParserError => e
      Rails.logger.error("[ResumeParser::TextStructurer] JSON parse failed: #{e.message}")
      nil
    rescue => e
      Rails.logger.error("[ResumeParser::TextStructurer] Failed: #{e.message}")
      nil
    end

    private

    attr_reader :profile

    def apply_structured_data(data)
      # Update contact details
      if data["contact"].present?
        profile.update!(contact_details: profile.contact_details.merge(data["contact"].compact_blank))
      end
      profile.update!(headline: data["headline"]) if data["headline"].present?
      profile.update!(summary: data["summary"]) if data["summary"].present?

      # Create sections and entries
      create_section_entries("work_experience", data["work_experience"])
      create_section_entries("education", data["education"])
      create_section_entries("skills", data["skills"])
      create_section_entries("certifications", data["certifications"])
      create_section_entries("languages", data["languages"])
    end

    def create_section_entries(section_type, entries)
      return if entries.blank?

      section = profile.profile_sections.find_or_create_by!(section_type: section_type) do |s|
        s.title = ProfileSection::SECTION_TITLES[section_type]
      end

      return if section.profile_entries.any?

      entries.each do |entry_data|
        section.profile_entries.create!(content: entry_data.deep_stringify_keys)
      end
    end
  end
end
