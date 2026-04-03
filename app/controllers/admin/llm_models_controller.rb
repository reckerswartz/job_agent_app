module Admin
  class LlmModelsController < BaseController
    def index
      @models = LlmModel.includes(:llm_provider).order(:llm_provider_id, :name)
    end

    def update
      @model = LlmModel.find(params[:id])
      if @model.update(model_params)
        redirect_to admin_llm_models_path, notice: "#{@model.name} updated."
      else
        redirect_to admin_llm_models_path, alert: "Failed to update #{@model.name}."
      end
    end

    private

    def model_params
      params.require(:llm_model).permit(:active, :role)
    end
  end
end
