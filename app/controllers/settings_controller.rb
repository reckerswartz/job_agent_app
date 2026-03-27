class SettingsController < ApplicationController
  before_action :authenticate_user!
  layout "dashboard"

  def edit
    @settings = AppSetting::KNOWN_KEYS.map do |key, meta|
      setting = AppSetting.find_or_initialize_by(key: key)
      setting.description ||= meta[:description]
      setting
    end
  end

  def update
    params[:settings]&.each do |key, value|
      next unless AppSetting::KNOWN_KEYS.key?(key)
      next if value.blank?

      AppSetting.set(key, value)
    end

    redirect_to edit_settings_path, notice: "Settings saved successfully."
  end
end
