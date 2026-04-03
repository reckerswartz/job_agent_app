module Llm
  module Pipeline
    class JobMatch
      PROMPT = <<~PROMPT
        Compare this job listing with the candidate's profile and return a JSON analysis.
        Return ONLY valid JSON, no markdown or explanations.

        {
          "relevance_score": <0-100>,
          "recommendation": "<strong_match|good_match|partial_match|weak_match>",
          "reasons": ["reason1", "reason2", "reason3"],
          "skill_gaps": ["skill1", "skill2"],
          "salary_estimate": "$XX,XXX - $XX,XXX or null if unknown",
          "summary": "One sentence summary of fit"
        }
      PROMPT

      def initialize(listing, profile)
        @listing = listing
        @profile = profile
      end

      def analyze
        client = Llm::Client.for_feature("job_match")
        return nil unless client

        messages = [
          { role: "system", content: "You are a job matching analyst. Return only valid JSON." },
          { role: "user", content: build_prompt }
        ]

        result = client.chat(messages, user: profile.user, profile: profile, feature: "job_match")
        json_text = result[:content].to_s.strip.gsub(/\A```json?\n?/, "").gsub(/\n?```\z/, "")

        parsed = JSON.parse(json_text)
        store_analysis(parsed)
        parsed
      rescue JSON::ParserError => e
        Rails.logger.error("[Llm::Pipeline::JobMatch] JSON parse failed: #{e.message}")
        nil
      rescue => e
        Rails.logger.error("[Llm::Pipeline::JobMatch] Failed: #{e.message}")
        nil
      end

      private

      attr_reader :listing, :profile

      def build_prompt
        listing_text = <<~TEXT
          Job Title: #{listing.title}
          Company: #{listing.company}
          Location: #{listing.location}
          Salary: #{listing.salary_range || 'Not specified'}
          Remote: #{listing.remote_type || 'Not specified'}
          Type: #{listing.employment_type || 'Not specified'}
          Description: #{listing.description.to_s.truncate(2000)}
        TEXT

        profile_text = <<~TEXT
          Headline: #{profile.headline}
          Summary: #{profile.summary.to_s.truncate(500)}
          City: #{profile.contact_field('city')}
          Country: #{profile.contact_field('country')}
          Skills: #{profile_skills.join(', ')}
          Experience: #{profile_experience}
        TEXT

        "#{PROMPT}\n\nJOB LISTING:\n#{listing_text}\n\nCANDIDATE PROFILE:\n#{profile_text}"
      end

      def profile_skills
        section = profile.profile_sections.find_by(section_type: "skills")
        return [] unless section
        section.profile_entries.map { |e| e.content["name"] }.compact
      end

      def profile_experience
        section = profile.profile_sections.find_by(section_type: "work_experience")
        return "Not specified" unless section
        section.profile_entries.first(3).map { |e|
          "#{e.content['title']} at #{e.content['company']}"
        }.join("; ")
      end

      def store_analysis(parsed)
        existing = listing.match_breakdown || {}
        existing["llm_analysis"] = {
          relevance_score: parsed["relevance_score"],
          recommendation: parsed["recommendation"],
          reasons: parsed["reasons"],
          skill_gaps: parsed["skill_gaps"],
          salary_estimate: parsed["salary_estimate"],
          summary: parsed["summary"],
          analyzed_at: Time.current.iso8601
        }
        listing.update_column(:match_breakdown, existing)
      end
    end
  end
end
