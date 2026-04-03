class NotificationsController < ApplicationController
  before_action :authenticate_user!
  layout "dashboard"

  def index
    @pagy, @notifications = pagy(current_user.notifications.recent, limit: 20)
    current_user.notifications.unread.update_all(read_at: Time.current)
  end

  def mark_read
    notification = current_user.notifications.find(params[:id])
    notification.mark_read!
    redirect_back fallback_location: notifications_path
  end

  def mark_all_read
    current_user.notifications.unread.update_all(read_at: Time.current)
    redirect_back fallback_location: notifications_path, notice: "All notifications marked as read."
  end
end
