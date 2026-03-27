class ApplicationController < ActionController::Base
  include Pagy::Backend

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  layout :layout_by_resource

  private

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
