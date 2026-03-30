module Admin
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :require_admin!
    layout "dashboard"

    private

    def require_admin!
      redirect_to dashboard_path, alert: "Access denied." unless current_user.admin?
    end
  end
end
