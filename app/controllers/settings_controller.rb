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
    # Handle API key settings
    params[:settings]&.each do |key, value|
      next unless AppSetting::KNOWN_KEYS.key?(key)
      next if value.blank?

      AppSetting.set(key, value)
    end

    # Handle notification preferences
    if params[:notifications].present?
      prefs = {}
      params[:notifications].each do |key, value|
        prefs[key] = ActiveModel::Type::Boolean.new.cast(value)
      end
      current_user.update!(notification_settings: current_user.notification_settings.merge(prefs))
    end

    redirect_to edit_settings_path, notice: "Settings saved successfully."
  end
end
