class ActivityLogsController < ApplicationController
  include DataTableable
  before_action :authenticate_user!
  layout "dashboard"

  def index
    scope = current_user.activity_logs
    scope = scope.by_category(params[:category]) if params[:category].present?
    if params[:q].present?
      scope = scope.where("description ILIKE :q OR action ILIKE :q", q: "%#{ActivityLog.sanitize_sql_like(params[:q])}%")
    end
    @search_query = params[:q]
    scope = apply_sorting(scope, %w[created_at action category], default_column: "created_at")
    @pagy, @activity_logs = pagy(scope, limit: per_page_limit)
    @category_counts = current_user.activity_logs.group(:category).count
  end
end
