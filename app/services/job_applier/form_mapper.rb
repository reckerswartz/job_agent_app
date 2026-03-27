module JobApplier
  class FormMapper
    FIELD_MAPPINGS = {
      "first_name" => :first_name,
      "last_name" => :surname,
      "surname" => :surname,
      "email" => :email,
      "phone" => :phone,
      "city" => :city,
      "country" => :country,
      "linkedin" => :linkedin,
      "website" => :website
    }.freeze

    def initialize(profile)
      @profile = profile
    end

    def map_fields(form_fields)
      mapped = {}
      form_fields.each do |field_name|
        normalized = field_name.to_s.downcase.gsub(/[\s\-_]+/, "_").strip
        value = resolve_value(normalized)
        mapped[field_name] = value if value.present?
      end
      mapped
    end

    def to_form_data
      {
        "first_name" => profile.contact_field("first_name"),
        "last_name" => profile.contact_field("surname"),
        "email" => profile.contact_field("email"),
        "phone" => profile.contact_field("phone"),
        "city" => profile.contact_field("city"),
        "country" => profile.contact_field("country"),
        "linkedin" => profile.contact_field("linkedin"),
        "website" => profile.contact_field("website"),
        "full_name" => profile.display_name,
        "headline" => profile.headline,
        "summary" => profile.summary,
        "current_title" => current_title,
        "current_company" => current_company,
        "experience_years" => experience_years
      }.compact_blank
    end

    private

    attr_reader :profile

    def resolve_value(normalized_name)
      if FIELD_MAPPINGS.key?(normalized_name)
        profile.contact_field(FIELD_MAPPINGS[normalized_name].to_s)
      elsif normalized_name.include?("name") && normalized_name.include?("full")
        profile.display_name
      elsif normalized_name.include?("title") || normalized_name.include?("position")
        current_title
      elsif normalized_name.include?("company") || normalized_name.include?("employer")
        current_company
      elsif normalized_name.include?("experience") || normalized_name.include?("years")
        experience_years.to_s
      elsif normalized_name.include?("summary") || normalized_name.include?("about")
        profile.summary
      end
    end

    def current_title
      latest_experience&.dig("title")
    end

    def current_company
      latest_experience&.dig("company")
    end

    def experience_years
      work_section = profile.profile_sections.find_by(section_type: "work_experience")
      return nil unless work_section

      entries = work_section.profile_entries.to_a
      return nil if entries.empty?

      entries.size * 2
    end

    def latest_experience
      @latest_experience ||= begin
        work_section = profile.profile_sections.find_by(section_type: "work_experience")
        return nil unless work_section

        work_section.profile_entries.first&.content
      end
    end
  end
end
