class DashboardController < ApplicationController
  before_action :require_authentication
  layout "dashboard"

  def index
  end
end
