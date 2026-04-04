module Admin
  class LlmModelsController < BaseController
    include DataTableable

    def index
      scope = LlmModel.includes(:llm_provider)

      # Filter tabs
      @filter = params[:show].presence || "active"
      case @filter
      when "active"   then scope = scope.where(active: true)
      when "tested"   then scope = scope.where(active: true, verification_status: "ok")
      when "inactive" then scope = scope.where(active: false)
      end

      scope = scope.where("llm_models.name ILIKE :q OR llm_models.identifier ILIKE :q", q: "%#{params[:q]}%") if params[:q].present?
      scope = apply_sorting(scope, %w[name model_type priority verification_status active], default_column: "priority")
      @pagy, @models = pagy(scope, limit: per_page_limit)
      @provider = LlmProvider.active.first

      # Tab counts
      @counts = {
        all: LlmModel.count,
        active: LlmModel.where(active: true).count,
        tested: LlmModel.where(active: true, verification_status: "ok").count,
        inactive: LlmModel.where(active: false).count
      }
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
      permitted = params.require(:llm_model).permit(:active, :priority)
      # Handle role separately — only allow known values (resolves Brakeman mass-assignment warning)
      role_value = params.dig(:llm_model, :role)
      permitted[:role] = role_value.in?(LlmModel::ROLES) ? role_value : nil if params[:llm_model].key?(:role)
      permitted
    end
  end
end
