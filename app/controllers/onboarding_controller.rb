class OnboardingController < ApplicationController
  before_action :authenticate_user!
  layout "auth"

  STEPS = %w[resume profile source complete].freeze

  def show
    @step = determine_current_step
    @profile = current_user.profiles.first_or_create!(title: "My Resume")
  end

  def update_step
    @step = params[:step]
    @profile = current_user.profiles.first_or_create!(title: "My Resume")

    case @step
    when "resume"
      save_resume
    when "profile"
      save_profile
    when "source"
      save_source
    when "complete"
      current_user.update!(onboarding_completed: true)
      trigger_first_scan
      redirect_to dashboard_path, notice: "Welcome to Job Agent! Your first job scan has started."
      return
    end

    next_step = STEPS[STEPS.index(@step).to_i + 1] || "complete"
    redirect_to onboarding_path(step: next_step)
  end

  def skip_step
    current_step = params[:step]
    next_step = STEPS[STEPS.index(current_step).to_i + 1] || "complete"
    redirect_to onboarding_path(step: next_step)
  end

  private

  def determine_current_step
    step = params[:step]
    STEPS.include?(step) ? step : STEPS.first
  end

  def trigger_first_scan
    sources = current_user.job_sources.enabled
    return if sources.none?

    criteria = current_user.job_search_criteria.where(is_default: true).first
    sources.each do |source|
      JobScanJob.perform_later(source.id, criteria&.id)
    end
  end

  def save_resume
    if params[:source_document].present?
      @profile.source_document.attach(params[:source_document])
      @profile.update!(source_mode: "upload")
      ResumeParseJob.perform_later(@profile.id)
    elsif params[:linkedin_url].present?
      import_linkedin_profile(params[:linkedin_url])
    end
  end

  def import_linkedin_profile(url)
    data = LinkedInProfileScraper.new(url).scrape
    return unless data

    updates = {}
    if data[:name].present?
      parts = data[:name].split(" ", 2)
      contact = @profile.contact_details.merge(
        "first_name" => parts[0].to_s.strip,
        "surname" => parts[1].to_s.strip,
        "linkedin" => data[:linkedin_url]
      )
      updates[:contact_details] = contact
    end
    updates[:headline] = data[:headline] if data[:headline].present?
    updates[:summary] = data[:summary] if data[:summary].present?

    if data[:location].present?
      loc_parts = data[:location].split(",").map(&:strip)
      contact = (updates[:contact_details] || @profile.contact_details).merge(
        "city" => loc_parts[0].to_s,
        "country" => loc_parts[-1].to_s
      )
      updates[:contact_details] = contact
    end

    @profile.update!(updates) if updates.any?
  end

  def save_profile
    updates = {}
    updates[:headline] = params.dig(:profile, :headline) if params.dig(:profile, :headline).present?
    updates[:summary] = params.dig(:profile, :summary) if params.dig(:profile, :summary).present?

    contact = @profile.contact_details.merge(
      "first_name" => params.dig(:profile, :first_name).to_s.strip,
      "surname" => params.dig(:profile, :surname).to_s.strip,
      "email" => params.dig(:profile, :email).to_s.strip,
      "phone" => params.dig(:profile, :phone).to_s.strip,
      "city" => params.dig(:profile, :city).to_s.strip,
      "country" => params.dig(:profile, :country).to_s.strip
    )
    updates[:contact_details] = contact
    @profile.update!(updates)
  end

  def save_source
    platform = params.dig(:job_source, :platform)
    return if platform.blank?

    source = current_user.job_sources.create!(
      name: "My #{platform.capitalize}",
      platform: platform
    )

    # Create search criteria from optional fields
    keywords = params.dig(:criteria, :keywords)
    if keywords.present?
      current_user.job_search_criteria.create!(
        name: "#{keywords} search",
        keywords: keywords,
        location: params.dig(:criteria, :location),
        remote_preference: params.dig(:criteria, :remote_preference).presence || "any",
        is_default: true
      )
    end
  end
end
