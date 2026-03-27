class JobSearchCriteriaController < ApplicationController
  before_action :authenticate_user!
  layout "dashboard"

  before_action :set_criteria, only: [:edit, :update, :destroy, :set_default]

  def index
    @criteria = current_user.job_search_criteria.order(is_default: :desc, created_at: :desc)
  end

  def new
    @criteria_item = current_user.job_search_criteria.build
  end

  def create
    @criteria_item = current_user.job_search_criteria.build(criteria_params)

    if @criteria_item.save
      redirect_to job_search_criteria_path, notice: "Search criteria '#{@criteria_item.name}' created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @criteria_item.update(criteria_params)
      redirect_to job_search_criteria_path, notice: "Search criteria updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    name = @criteria_item.name
    @criteria_item.destroy
    redirect_to job_search_criteria_path, notice: "'#{name}' removed."
  end

  def set_default
    @criteria_item.update!(is_default: true)
    redirect_to job_search_criteria_path, notice: "'#{@criteria_item.name}' set as default."
  end

  private

  def set_criteria
    @criteria_item = current_user.job_search_criteria.find(params[:id])
  end

  def criteria_params
    params.require(:job_search_criteria).permit(
      :name, :keywords, :location, :remote_preference,
      :experience_level, :salary_min, :salary_max, :job_type,
      :excluded_companies
    )
  end
end
