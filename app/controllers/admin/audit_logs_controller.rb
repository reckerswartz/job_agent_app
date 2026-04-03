module Admin
  class AuditLogsController < BaseController
    include DataTableable

    def index
      scope = ActivityLog.includes(:user)
      scope = scope.by_category(params[:category]) if params[:category].present?
      scope = scope.where(user_id: params[:user_id]) if params[:user_id].present?
      scope = apply_sorting(scope, %w[created_at action category user_id], default_column: "created_at")
      @pagy, @logs = pagy(scope, limit: per_page_limit)
      @category_counts = ActivityLog.group(:category).count
    end
  end
end
