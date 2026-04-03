module Admin
  class LlmModelsController < BaseController
    def index
      @models = LlmModel.includes(:llm_provider).order(:llm_provider_id, priority: :desc, name: :asc)
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

      results = Llm::ModelVerifier.new(provider).verify_all
      ok_count = results.values.count { |r| r[:status] == "ok" }
      fail_count = results.values.count { |r| r[:status] != "ok" }
      redirect_to admin_llm_models_path, notice: "Verified #{results.size} models: #{ok_count} OK, #{fail_count} failed."
    end

    def verify_one
      model = LlmModel.find(params[:id])
      provider = model.llm_provider
      result = Llm::ModelVerifier.new(provider).verify(model)
      redirect_to admin_llm_models_path, notice: "#{model.name}: #{result[:status]} (#{result[:latency_ms]}ms)" if result[:status] == "ok"
      redirect_to admin_llm_models_path, alert: "#{model.name}: #{result[:status]} — #{result[:error]}" unless result[:status] == "ok"
    end

    private

    def model_params
      params.require(:llm_model).permit(:active, :role, :priority)
    end
  end
end
