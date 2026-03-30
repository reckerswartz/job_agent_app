module Admin
  class UsersController < BaseController
    before_action :set_user, only: [ :show, :toggle_role ]

    def index
      @pagy, @users = pagy(User.order(created_at: :desc))
    end

    def show
      @sources_count = @user.job_sources.count
      @listings_count = JobListing.for_user(@user).count
      @applications_count = JobApplication.for_user(@user).count
      @recent_scans = JobScanRun.joins(:job_source).where(job_sources: { user_id: @user.id }).recent.limit(5)
    end

    def toggle_role
      new_role = @user.admin? ? :user : :admin
      @user.update!(role: new_role)
      redirect_to admin_user_path(@user), notice: "#{@user.email} role changed to #{new_role}."
    end

    private

    def set_user
      @user = User.find(params[:id])
    end
  end
end
