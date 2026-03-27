class JobScanRunsController < ApplicationController
  before_action :authenticate_user!
  layout "dashboard"

  before_action :set_job_source

  def index
    @scan_runs = @job_source.job_scan_runs.recent
  end

  def show
    @scan_run = @job_source.job_scan_runs.find(params[:id])
  end

  def create
    criteria = current_user.job_search_criteria.default_criteria.first
    JobScanJob.perform_later(@job_source.id, criteria&.id)
    redirect_to job_source_scan_runs_path(@job_source), notice: "Scan queued for #{@job_source.name}."
  end

  private

  def set_job_source
    @job_source = current_user.job_sources.find(params[:job_source_id])
  end
end
