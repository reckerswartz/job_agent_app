class ApplicationMailer < ActionMailer::Base
  default from: "noreply@jobagent.dev"
  layout "mailer"

  after_action :set_unsubscribe_header

  private

  def set_unsubscribe_header
    headers["List-Unsubscribe"] = "<#{edit_settings_url}>"
    headers["List-Unsubscribe-Post"] = "List-Unsubscribe=One-Click"
  end
end
