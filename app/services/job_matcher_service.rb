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
    @breakdown = {}
  end

  def call
    return 0 if profile.nil?

    total = 0
    WEIGHTS.each do |category, weight|
      cat_score = send(:"#{category}_score")
      total += cat_score * weight / 100.0
    end

    final = total.round.clamp(0, 100)

    # Store breakdown on the listing for UI display
    if listing.persisted? && listing.respond_to?(:match_breakdown=)
      listing.update_column(:match_breakdown, @breakdown)
    end

    final
  end

  def breakdown
    @breakdown
  end

  private

  attr_reader :listing, :profile

  def title_score
    return store_breakdown(:title, 0) if listing.title.blank?

    headline = profile.headline.to_s.downcase
    title = listing.title.downcase
    profile_keywords = extract_keywords(headline)

    if title.include?(headline) && headline.present?
      return store_breakdown(:title, 100, matched: profile_keywords, missing: [])
    end

    return store_breakdown(:title, 0, matched: [], missing: []) if profile_keywords.empty?

    matched_kw = profile_keywords.select { |kw| title.include?(kw) }
    missed_kw = profile_keywords - matched_kw
    score = (matched_kw.size.to_f / profile_keywords.size * 100).round

    store_breakdown(:title, score, matched: matched_kw, missing: missed_kw)
  end

  def skills_score
    skills_section = profile.profile_sections.find_by(section_type: "skills")
    return store_breakdown(:skills, 50, matched: [], missing: [], detail: "No skills in profile") if skills_section.nil?

    skill_names = skills_section.profile_entries.map { |e| e.content["name"].to_s.downcase }.reject(&:blank?)
    return store_breakdown(:skills, 50, matched: [], missing: [], detail: "No skills in profile") if skill_names.empty?

    text = "#{listing.title} #{listing.description} #{listing.requirements}".downcase
    matched_skills = skill_names.select { |skill| text.include?(skill) }
    missing_skills = skill_names - matched_skills
    score = (matched_skills.size.to_f / skill_names.size * 100).round

    store_breakdown(:skills, score, matched: matched_skills, missing: missing_skills)
  end

  def location_score
    if listing.remote_type == "remote"
      return store_breakdown(:location, 80, detail: "Remote position")
    end
    return store_breakdown(:location, 50, detail: "No location data") if listing.location.blank?

    user_city = profile.contact_field("city").to_s.downcase
    user_country = profile.contact_field("country").to_s.downcase
    listing_loc = listing.location.to_s.downcase

    if user_city.present? && listing_loc.include?(user_city)
      return store_breakdown(:location, 100, detail: "City match: #{user_city}")
    end
    if user_country.present? && listing_loc.include?(user_country)
      return store_breakdown(:location, 75, detail: "Country match: #{user_country}")
    end

    store_breakdown(:location, 30, detail: "Location mismatch")
  end

  def salary_score
    if listing.salary_range.blank?
      return store_breakdown(:salary, 50, detail: "No salary info")
    end
    store_breakdown(:salary, 70, detail: listing.salary_range)
  end

  def recency_score
    if listing.posted_at.nil?
      return store_breakdown(:recency, 50, detail: "Unknown date")
    end

    days_ago = (Time.current - listing.posted_at) / 1.day
    score = case days_ago
    when 0..1   then 100
    when 1..3   then 90
    when 3..7   then 75
    when 7..14  then 50
    when 14..30 then 25
    else 10
    end

    store_breakdown(:recency, score, detail: "#{days_ago.round} days ago")
  end

  def source_score
    platform = listing.job_source&.platform
    score = case platform
    when "linkedin"  then 90
    when "indeed"    then 80
    when "glassdoor" then 75
    when "naukri"    then 70
    when "wellfound" then 65
    else 50
    end

    store_breakdown(:source, score, detail: platform&.capitalize || "Unknown")
  end

  def store_breakdown(category, score, **extras)
    @breakdown[category] = { score: score, weight: WEIGHTS[category] }.merge(extras)
    score
  end

  def extract_keywords(text)
    stop_words = %w[a an the and or in at for to of on with as by is are was were]
    text.split(/[\s,\-\/]+/).map(&:downcase).reject { |w| w.length < 2 || stop_words.include?(w) }.uniq
  end
end
