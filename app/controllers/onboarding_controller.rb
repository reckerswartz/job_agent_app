class OnboardingController < ApplicationController
  before_action :authenticate_user!
  layout "auth"

  STEPS = %w[welcome profile resume source criteria complete].freeze

  def show
    @step = determine_current_step
  end

  def update_step
    @step = params[:step]

    case @step
    when "profile"
      save_profile
    when "resume"
      save_resume
    when "source"
      save_source
    when "criteria"
      save_criteria
    when "complete"
      current_user.update!(onboarding_completed: true)
      redirect_to dashboard_path, notice: "Welcome to Job Agent! You're all set."
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
    STEPS.include?(step) ? step : "welcome"
  end

  def save_profile
    profile = current_user.profiles.first_or_create!(title: "My Resume")
    profile.update!(
      headline: params.dig(:profile, :headline),
      contact_details: profile.contact_details.merge(
        "first_name" => params.dig(:profile, :first_name).to_s.strip,
        "surname" => params.dig(:profile, :surname).to_s.strip,
        "email" => params.dig(:profile, :email).to_s.strip,
        "phone" => params.dig(:profile, :phone).to_s.strip
      )
    )
  end

  def save_resume
    profile = current_user.profiles.first_or_create!(title: "My Resume")
    if params[:source_document].present?
      profile.source_document.attach(params[:source_document])
      profile.update!(source_mode: "upload")
      ResumeParseJob.perform_later(profile.id)
    end
  end

  def save_source
    return if params.dig(:job_source, :platform).blank?

    current_user.job_sources.create!(
      name: params.dig(:job_source, :name).presence || "My #{params.dig(:job_source, :platform).capitalize}",
      platform: params.dig(:job_source, :platform)
    )
  end

  def save_criteria
    return if params.dig(:criteria, :keywords).blank?

    current_user.job_search_criteria.create!(
      name: "#{params.dig(:criteria, :keywords)} search",
      keywords: params.dig(:criteria, :keywords),
      location: params.dig(:criteria, :location),
      remote_preference: params.dig(:criteria, :remote_preference).presence || "any",
      is_default: true
    )
  end
end
