module Pdf
  class ResumePdf
    def initialize(profile, tailored_data = nil)
      @profile = profile
      @tailored = tailored_data
    end

    def render
      Prawn::Document.new(page_size: "LETTER", margin: [54, 54, 54, 54]) do |pdf|
        render_header(pdf)
        render_summary(pdf)
        render_experience(pdf)
        render_education(pdf)
        render_skills(pdf)
        render_certifications(pdf)
      end.render
    end

    private

    attr_reader :profile, :tailored

    def render_header(pdf)
      pdf.text profile.display_name, size: 20, style: :bold
      pdf.text profile.headline.to_s, size: 11, color: "444444"
      contact = [
        profile.contact_field("email"), profile.contact_field("phone"),
        profile.contact_field("city"), profile.contact_field("country")
      ].reject(&:blank?).join(" | ")
      pdf.text contact, size: 9, color: "888888" if contact.present?
      linkedin = profile.contact_field("linkedin")
      pdf.text linkedin, size: 9, color: "1E3A5F" if linkedin.present?
      pdf.stroke_horizontal_rule
      pdf.move_down 12
    end

    def render_summary(pdf)
      summary_text = tailored&.dig("tailored_summary") || profile.summary
      return if summary_text.blank?

      pdf.text "PROFESSIONAL SUMMARY", size: 11, style: :bold, color: "1E3A5F"
      pdf.move_down 4
      pdf.text summary_text, size: 10, leading: 3
      if tailored&.dig("experience_highlights").present?
        pdf.move_down 4
        tailored["experience_highlights"].each do |highlight|
          pdf.text "• #{highlight}", size: 10, color: "333333"
        end
      end
      pdf.move_down 10
    end

    def render_experience(pdf)
      section = profile.profile_sections.find_by(section_type: "work_experience")
      return unless section&.profile_entries&.any?

      pdf.text "WORK EXPERIENCE", size: 11, style: :bold, color: "1E3A5F"
      pdf.move_down 4
      section.profile_entries.each do |entry|
        c = entry.content
        pdf.text "#{c['title']}", size: 10, style: :bold
        dates = [c["start_date"], c["end_date"] || "Present"].compact.join(" – ")
        pdf.text "#{c['company']}  |  #{dates}", size: 9, color: "666666"
        pdf.text c["description"].to_s, size: 9, leading: 2 if c["description"].present?
        pdf.move_down 6
      end
      pdf.move_down 6
    end

    def render_education(pdf)
      section = profile.profile_sections.find_by(section_type: "education")
      return unless section&.profile_entries&.any?

      pdf.text "EDUCATION", size: 11, style: :bold, color: "1E3A5F"
      pdf.move_down 4
      section.profile_entries.each do |entry|
        c = entry.content
        pdf.text "#{c['degree']} — #{c['field']}", size: 10, style: :bold
        dates = [c["start_date"], c["end_date"]].compact.join(" – ")
        pdf.text "#{c['institution']}  |  #{dates}", size: 9, color: "666666"
        pdf.move_down 4
      end
      pdf.move_down 6
    end

    def render_skills(pdf)
      section = profile.profile_sections.find_by(section_type: "skills")
      return unless section&.profile_entries&.any?

      highlighted = tailored&.dig("highlighted_skills")&.map(&:downcase) || []
      skill_names = section.profile_entries.map { |e| e.content["name"] }.compact

      pdf.text "SKILLS", size: 11, style: :bold, color: "1E3A5F"
      pdf.move_down 4
      skill_names.each_slice(6) do |row|
        line = row.map { |s| highlighted.include?(s.downcase) ? "★ #{s}" : s }.join("  •  ")
        pdf.text line, size: 9
      end
      pdf.move_down 6
    end

    def render_certifications(pdf)
      section = profile.profile_sections.find_by(section_type: "certifications")
      return unless section&.profile_entries&.any?

      pdf.text "CERTIFICATIONS", size: 11, style: :bold, color: "1E3A5F"
      pdf.move_down 4
      section.profile_entries.each do |entry|
        c = entry.content
        pdf.text "#{c['name']} — #{c['issuer']}", size: 10
        pdf.text c["date"].to_s, size: 9, color: "666666" if c["date"].present?
        pdf.move_down 3
      end
    end
  end
end
