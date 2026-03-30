class JobSourcesController < ApplicationController
  before_action :authenticate_user!
  layout "dashboard"

  before_action :set_job_source, only: [ :edit, :update, :destroy, :toggle ]

  def index
    @job_sources = current_user.job_sources.order(created_at: :desc)
  end

  def new
    @job_source = current_user.job_sources.build
  end

  def create
    @job_source = current_user.job_sources.build(job_source_params)

    if @job_source.save
      redirect_to job_sources_path, notice: "#{@job_source.name} added successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @job_source.update(job_source_params)
      redirect_to job_sources_path, notice: "#{@job_source.name} updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    name = @job_source.name
    @job_source.destroy
    redirect_to job_sources_path, notice: "#{name} removed."
  end

  def toggle
    @job_source.update!(enabled: !@job_source.enabled)
    status = @job_source.enabled? ? "enabled" : "disabled"
    redirect_to job_sources_path, notice: "#{@job_source.name} #{status}."
  end

  private

  def set_job_source
    @job_source = current_user.job_sources.find(params[:id])
  end

  def job_source_params
    params.require(:job_source).permit(:name, :platform, :base_url, :scan_interval_hours,
                                       credentials: [ :username, :password ])
  end
end
