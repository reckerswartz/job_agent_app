module Llm
  class Pipeline
    class CoverLetter
      PROMPT = <<~PROMPT
        Write a professional cover letter for the following job application.
        Keep it concise (3-4 paragraphs), professional, and focused on fit.
        Do not include placeholder text — write a complete, ready-to-send letter.

        Job Title: %{title}
        Company: %{company}
        Job Description: %{description}

        Candidate Name: %{name}
        Candidate Headline: %{headline}
        Candidate Summary: %{summary}
        Key Skills: %{skills}
      PROMPT

      def initialize(pipeline = nil)
        @pipeline = pipeline || Pipeline.new
      end

      def generate(listing, profile, user:)
        return nil unless pipeline.available? && pipeline.text_model

        prompt_text = format(PROMPT,
          title: listing.title,
          company: listing.company,
          description: listing.description.to_s.truncate(2000),
          name: profile.display_name,
          headline: profile.headline,
          summary: profile.summary.to_s.truncate(500),
          skills: skill_names(profile).join(", ")
        )

        messages = [
          { role: "system", content: "You are an expert career coach who writes compelling cover letters." },
          { role: "user", content: prompt_text }
        ]

        result = pipeline.client.chat(
          messages, model: pipeline.text_model,
          user: user, profile: profile, feature: "cover_letter"
        )

        cover_letter = result[:content]
        cover_letter = verify_quality(cover_letter, listing, user: user, profile: profile) if pipeline.verification_model
        cover_letter
      rescue => e
        Rails.logger.error("[Llm::Pipeline::CoverLetter] Generation failed: #{e.message}")
        nil
      end

      private

      attr_reader :pipeline

      def verify_quality(letter, listing, user:, profile:)
        messages = [
          { role: "system", content: "Review this cover letter for quality. If it's good, return it unchanged. If it needs improvement, return the improved version. Return only the letter text." },
          { role: "user", content: "Cover letter for #{listing.title} at #{listing.company}:\n\n#{letter}" }
        ]

        result = pipeline.client.chat(
          messages, model: pipeline.verification_model,
          user: user, profile: profile, feature: "cover_letter"
        )
        result[:content].presence || letter
      rescue => e
        Rails.logger.warn("[Llm::Pipeline::CoverLetter] Verification failed, using unverified: #{e.message}")
        letter
      end

      def skill_names(profile)
        skills_section = profile.profile_sections.find_by(section_type: "skills")
        return [] unless skills_section

        skills_section.profile_entries.map { |e| e.content["name"] }.compact
      end
    end
  end
end
