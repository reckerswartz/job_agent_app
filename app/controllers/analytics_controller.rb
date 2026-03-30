class AnalyticsController < ApplicationController
  before_action :authenticate_user!
  layout "dashboard"

  def index
    @analytics = AnalyticsService.new(current_user)
  end
end
