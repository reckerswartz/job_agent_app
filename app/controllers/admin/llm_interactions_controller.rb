module Admin
  class LlmInteractionsController < BaseController
    def index
      @pagy, @interactions = pagy(
        LlmInteraction.recent.includes(:user, :llm_provider, :llm_model),
        limit: 25
      )
    end

    def show
      @interaction = LlmInteraction.find(params[:id])
    end
  end
end
