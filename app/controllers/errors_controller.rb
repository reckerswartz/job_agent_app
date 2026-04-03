class ErrorsController < ApplicationController
  layout "auth"
  skip_before_action :check_onboarding!, raise: false

  def not_found
    render status: :not_found
  end

  def unprocessable
    render status: :unprocessable_entity
  end

  def internal_error
    render status: :internal_server_error
  end
end
