module Admin
  class LlmInteractionsController < BaseController
    include DataTableable

    def index
      scope = LlmInteraction.includes(:user, :llm_provider, :llm_model)
      scope = scope.where(feature_name: params[:feature]) if params[:feature].present?
      scope = scope.where(status: params[:status]) if params[:status].present?
      scope = apply_sorting(scope, %w[created_at feature_name status latency_ms], default_column: "created_at")
      @pagy, @interactions = pagy(scope, limit: per_page_limit)
    end

    def show
      @interaction = LlmInteraction.find(params[:id])
    end
  end
end
