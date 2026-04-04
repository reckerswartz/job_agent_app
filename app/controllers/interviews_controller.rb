class InterviewsController < ApplicationController
  before_action :authenticate_user!
  layout "dashboard"

  before_action :set_application
  before_action :set_interview, only: [ :update, :destroy, :generate_prep ]

  def create
    @interview = @application.interviews.build(interview_params)
    if @interview.save
      redirect_to job_application_path(@application), notice: "Interview added."
    else
      redirect_to job_application_path(@application), alert: "Failed to add interview: #{@interview.errors.full_messages.join(', ')}"
    end
  end

  def update
    if @interview.update(interview_params)
      redirect_to job_application_path(@application), notice: "Interview updated."
    else
      redirect_to job_application_path(@application), alert: "Failed to update interview."
    end
  end

  def destroy
    @interview.destroy
    redirect_to job_application_path(@application), notice: "Interview removed."
  end

  def generate_prep
    questions = InterviewPrepService.new(@interview).generate_questions
    if questions
      redirect_to job_application_path(@application), notice: "#{questions.size} prep questions generated."
    else
      redirect_to job_application_path(@application), alert: "Could not generate questions. Check LLM configuration."
    end
  end

  private

  def set_application
    @application = JobApplication.for_user(current_user).find(params[:job_application_id])
  end

  def set_interview
    @interview = @application.interviews.find(params[:id])
  end

  def interview_params
    params.require(:interview).permit(:stage, :scheduled_at, :interviewer_name, :location, :format, :notes, :status, :rating)
  end
end
