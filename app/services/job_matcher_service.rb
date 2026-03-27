class JobMatcherService
  WEIGHTS = {
    title: 30,
    skills: 25,
    location: 15,
    salary: 15,
    recency: 10,
    source: 5
  }.freeze

  def initialize(listing, profile)
    @listing = listing
    @profile = profile
  end

  def call
    return 0 if profile.nil?

    score = 0
    score += title_score * WEIGHTS[:title] / 100.0
    score += skills_score * WEIGHTS[:skills] / 100.0
    score += location_score * WEIGHTS[:location] / 100.0
    score += salary_score * WEIGHTS[:salary] / 100.0
    score += recency_score * WEIGHTS[:recency] / 100.0
    score += source_score * WEIGHTS[:source] / 100.0

    score.round.clamp(0, 100)
  end

  private

  attr_reader :listing, :profile

  def title_score
    return 0 if listing.title.blank?

    headline = profile.headline.to_s.downcase
    title = listing.title.downcase
    profile_keywords = extract_keywords(headline)

    return 100 if title.include?(headline) && headline.present?

    matched = profile_keywords.count { |kw| title.include?(kw) }
    return 0 if profile_keywords.empty?

    (matched.to_f / profile_keywords.size * 100).round
  end

  def skills_score
    skills_section = profile.profile_sections.find_by(section_type: "skills")
    return 50 if skills_section.nil?

    skill_names = skills_section.profile_entries.map { |e| e.content["name"].to_s.downcase }.reject(&:blank?)
    return 50 if skill_names.empty?

    text = "#{listing.title} #{listing.description} #{listing.requirements}".downcase
    matched = skill_names.count { |skill| text.include?(skill) }

    (matched.to_f / skill_names.size * 100).round
  end

  def location_score
    return 80 if listing.remote_type == "remote"
    return 50 if listing.location.blank?

    user_city = profile.contact_field("city").to_s.downcase
    user_country = profile.contact_field("country").to_s.downcase
    listing_loc = listing.location.to_s.downcase

    return 100 if user_city.present? && listing_loc.include?(user_city)
    return 75 if user_country.present? && listing_loc.include?(user_country)

    30
  end

  def salary_score
    return 50 if listing.salary_range.blank?

    70
  end

  def recency_score
    return 50 if listing.posted_at.nil?

    days_ago = (Time.current - listing.posted_at) / 1.day
    case days_ago
    when 0..1   then 100
    when 1..3   then 90
    when 3..7   then 75
    when 7..14  then 50
    when 14..30 then 25
    else 10
    end
  end

  def source_score
    case listing.job_source&.platform
    when "linkedin" then 90
    when "indeed"   then 80
    when "glassdoor" then 75
    when "naukri"   then 70
    when "wellfound" then 65
    else 50
    end
  end

  def extract_keywords(text)
    stop_words = %w[a an the and or in at for to of on with as by is are was were]
    text.split(/[\s,\-\/]+/).map(&:downcase).reject { |w| w.length < 2 || stop_words.include?(w) }.uniq
  end
end
