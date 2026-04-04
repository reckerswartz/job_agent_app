class AnalyticsController < ApplicationController
  before_action :authenticate_user!
  layout "dashboard"

  def index
    @period = params[:period].presence || "all"
    @analytics = AnalyticsService.new(current_user, period: @period)
  end
end
