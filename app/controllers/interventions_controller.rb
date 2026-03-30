class InterventionsController < ApplicationController
  before_action :authenticate_user!
  layout "dashboard"

  before_action :set_intervention, only: [ :show, :resolve, :dismiss ]

  def index
    scope = current_user.interventions.recent.includes(:interventionable)
    scope = scope.where(status: params[:status]) if params[:status].present?
    @pagy, @interventions = pagy(scope)
    @status_counts = current_user.interventions.group(:status).count
    @pending_count = @status_counts["pending"] || 0
  end

  def show
  end

  def resolve
    input = user_input_params
    @intervention.resolve!(input)

    retry_parent(@intervention)

    redirect_to interventions_path, notice: "Intervention resolved. Retrying automatically."
  end

  def dismiss
    @intervention.dismiss!
    redirect_to interventions_path, notice: "Intervention dismissed."
  end

  private

  def set_intervention
    @intervention = current_user.interventions.find(params[:id])
  end

  def user_input_params
    return {} unless params[:user_input].present?

    params.require(:user_input).permit(
      :username, :password, :captcha_answer, :manually_solved,
      :account_created, :field_value, :notes, :verified
    ).to_h
  end

  def retry_parent(intervention)
    case intervention.interventionable
    when JobApplication
      app = intervention.interventionable
      if app.can_retry?
        app.application_steps.destroy_all
        app.update!(status: "queued", error_details: {})
        JobApplyJob.perform_later(app.id)
      end
    when JobScanRun
      run = intervention.interventionable
      if run.failed?
        source = run.job_source
        criteria = run.job_search_criteria
        JobScanJob.perform_later(source.id, criteria&.id)
      end
    when JobSource
      source = intervention.interventionable
      source.update!(status: "active") if source.status == "needs_login"
    end
  end
end
