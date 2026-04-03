module Admin
  class LlmModelsController < BaseController
    include DataTableable

    def index
      scope = LlmModel.includes(:llm_provider)
      scope = scope.where("llm_models.name ILIKE :q OR llm_models.identifier ILIKE :q", q: "%#{params[:q]}%") if params[:q].present?
      scope = apply_sorting(scope, %w[name model_type priority verification_status active], default_column: "priority")
      @pagy, @models = pagy(scope, limit: per_page_limit)
      @provider = LlmProvider.active.first
    end

    def update
      @model = LlmModel.find(params[:id])
      if @model.update(model_params)
        redirect_to admin_llm_models_path, notice: "#{@model.name} updated."
      else
        redirect_to admin_llm_models_path, alert: "Failed to update #{@model.name}."
      end
    end

    def sync
      provider = LlmProvider.active.first
      unless provider&.available?
        redirect_to admin_llm_models_path, alert: "No active provider with API key configured."
        return
      end

      result = Llm::ModelSyncService.new(provider).sync!
      if result[:error]
        redirect_to admin_llm_models_path, alert: "Sync failed: #{result[:error]}"
      else
        redirect_to admin_llm_models_path, notice: "Synced #{result[:total]} models (#{result[:added]} new, #{result[:updated]} updated, #{result[:deactivated]} deactivated)."
      end
    end

    def verify_all
      provider = LlmProvider.active.first
      unless provider&.available?
        redirect_to admin_llm_models_path, alert: "No active provider with API key configured."
        return
      end

      count = 0
      provider.llm_models.active.find_each do |model|
        LlmModelVerifyJob.perform_later(model.id)
        count += 1
      end

      redirect_to admin_llm_models_path, notice: "Verification started for #{count} models. Results will appear shortly."
    end

    def verify_one
      model = LlmModel.find(params[:id])
      LlmModelVerifyJob.perform_later(model.id)
      redirect_to admin_llm_models_path, notice: "Verification started for #{model.name}. Refresh to see results."
    end

    private

    def model_params
      params.require(:llm_model).permit(:active, :role, :priority)
    end
  end
end
