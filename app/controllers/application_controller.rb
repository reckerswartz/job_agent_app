class ApplicationController < ActionController::Base
  include Pagy::Backend

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :check_onboarding!, if: :user_signed_in?

  layout :layout_by_resource

  private

  def check_onboarding!
    return if current_user.onboarding_completed?
    return if controller_name == "onboarding"
    return if devise_controller?
    return if controller_name == "home"

    redirect_to onboarding_path
  end

  def layout_by_resource
    if devise_controller?
      "auth"
    else
      "application"
    end
  end

  def after_sign_in_path_for(resource)
    dashboard_path
  end

  def after_sign_out_path_for(resource_or_scope)
    root_path
  end
end
