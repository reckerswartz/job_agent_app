module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :set_current_session
    helper_method :authenticated?, :current_user
  end

  private

  def authenticated?
    Current.session.present?
  end

  def current_user
    Current.user
  end

  def require_authentication
    unless authenticated?
      redirect_to sign_in_path, alert: "Please sign in to continue."
    end
  end

  def set_current_session
    if session[:session_id]
      Current.session = Session.find_by(id: session[:session_id])
      session.delete(:session_id) unless Current.session
    end
  end

  def start_new_session_for(user)
    new_session = user.sessions.create!(
      ip_address: request.remote_ip,
      user_agent: request.user_agent
    )
    Current.session = new_session
    reset_session
    session[:session_id] = new_session.id
  end

  def terminate_session
    Current.session&.destroy
    session.delete(:session_id)
    Current.session = nil
  end
end
