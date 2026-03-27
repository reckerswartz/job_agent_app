module Llm
  class Pipeline
    class ResumeExtract
      VISION_PROMPT = "Extract all text from this resume image. Return the plain text content exactly as it appears, preserving structure and formatting. Do not summarize or interpret — just extract the raw text."

      STRUCTURE_PROMPT = <<~PROMPT
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
      PROMPT

      def initialize(pipeline = nil)
        @pipeline = pipeline || Pipeline.new
      end

      def extract_from_images(images, user:, profile:)
        return nil unless pipeline.available? && pipeline.vision_model

        extracted_texts = []

        if pipeline.vision_model.multimodal? && (pipeline.vision_model.max_images.nil? || images.size <= pipeline.vision_model.max_images.to_i)
          result = pipeline.client.vision(
            images.first, prompt: VISION_PROMPT,
            model: pipeline.vision_model, user: user, profile: profile, feature: "resume_parse"
          )
          extracted_texts << result[:content] if result[:content].present?
        else
          images.each do |image_data|
            result = pipeline.client.vision(
              image_data, prompt: VISION_PROMPT,
              model: pipeline.vision_model, user: user, profile: profile, feature: "resume_parse"
            )
            extracted_texts << result[:content] if result[:content].present?
          end
        end

        extracted_texts.join("\n\n---\n\n")
      rescue => e
        Rails.logger.error("[Llm::Pipeline::ResumeExtract] Vision extraction failed: #{e.message}")
        nil
      end

      def structure_text(raw_text, user:, profile:)
        return nil unless pipeline.available? && pipeline.text_model
        return nil if raw_text.blank?

        messages = [
          { role: "system", content: "You are a resume parser. Return only valid JSON." },
          { role: "user", content: "#{STRUCTURE_PROMPT}\n\nResume text:\n#{raw_text}" }
        ]

        result = pipeline.client.chat(
          messages, model: pipeline.text_model,
          user: user, profile: profile, feature: "resume_structure"
        )

        json_text = result[:content].to_s.strip.gsub(/\A```json?\n?/, "").gsub(/\n?```\z/, "")
        JSON.parse(json_text)
      rescue JSON::ParserError => e
        Rails.logger.error("[Llm::Pipeline::ResumeExtract] JSON parse failed: #{e.message}")
        nil
      rescue => e
        Rails.logger.error("[Llm::Pipeline::ResumeExtract] Text structuring failed: #{e.message}")
        nil
      end

      def verify(structured_data, raw_text, user:, profile:)
        return structured_data unless pipeline.verification_model

        verify_prompt = "Verify and correct this extracted resume data against the original text. Fix any errors. Return corrected JSON only.\n\nExtracted: #{structured_data.to_json}\n\nOriginal:\n#{raw_text.to_s.truncate(3000)}"
        messages = [
          { role: "system", content: "You are a data verification expert. Return only valid corrected JSON." },
          { role: "user", content: verify_prompt }
        ]

        result = pipeline.client.chat(
          messages, model: pipeline.verification_model,
          user: user, profile: profile, feature: "resume_structure"
        )

        json_text = result[:content].to_s.strip.gsub(/\A```json?\n?/, "").gsub(/\n?```\z/, "")
        JSON.parse(json_text)
      rescue => e
        Rails.logger.warn("[Llm::Pipeline::ResumeExtract] Verification failed, using unverified data: #{e.message}")
        structured_data
      end

      private

      attr_reader :pipeline
    end
  end
end
