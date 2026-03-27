module AuthenticationHelper
  def sign_in_as(user)
    # Create a DB session and inject session_id into the rack-test cookie jar
    # by making a request that sets the session. We avoid the controller's
    # reset_session which breaks rack-test cookie persistence.
    db_session = user.sessions.create!(ip_address: "127.0.0.1", user_agent: "RSpec")

    # Warm up cookies with a GET, then set the session_id via a PATCH to a
    # temporary endpoint. Simplest approach: just allow the concern to find it.
    allow_any_instance_of(Authentication).to receive(:set_current_session) do |controller|
      Current.session = db_session
    end
  end
end

RSpec.configure do |config|
  config.include AuthenticationHelper, type: :request
end
