module Admin
  class DashboardController < BaseController
    def index
      @total_users = User.count
      @total_listings = JobListing.count
      @total_applications = JobApplication.count
      @total_scans = JobScanRun.count
      @total_interventions = Intervention.count
      @pending_interventions = Intervention.pending.count

      @recent_users = User.order(created_at: :desc).limit(5)
      @recent_scans = JobScanRun.recent.limit(10).includes(:job_source)

      @llm_stats = {
        total: LlmInteraction.count,
        completed: LlmInteraction.completed.count,
        failed: LlmInteraction.failed.count
      }
    end
  end
end
