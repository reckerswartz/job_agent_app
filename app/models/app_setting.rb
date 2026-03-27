class AppSetting < ApplicationRecord
  KNOWN_KEYS = {
    "figma_api_key" => { description: "Figma API Key for design-to-code workflow", env_var: "FIGMA_API_KEY" },
    "miro_oauth_token" => { description: "Miro OAuth Token for whiteboard planning", env_var: "MIRO_OAUTH_TOKEN" },
    "tavily_api_key" => { description: "Tavily API Key for web search", env_var: "TAVILY_API_KEY" },
    "duckduckgo_api_key" => { description: "DuckDuckGo API Key for web search", env_var: "DUCKDUCKGO_API_KEY" }
  }.freeze

  encrypts :encrypted_value

  validates :key, presence: true, uniqueness: true

  def self.get(key)
    find_by(key: key)&.encrypted_value.presence || ENV[KNOWN_KEYS.dig(key, :env_var).to_s]
  end

  def self.set(key, value)
    setting = find_or_initialize_by(key: key)
    setting.encrypted_value = value
    setting.description ||= KNOWN_KEYS.dig(key, :description)
    setting.save!
  end

  def masked_value
    return nil if encrypted_value.blank?

    val = encrypted_value.to_s
    if val.length > 8
      "#{"*" * (val.length - 4)}#{val.last(4)}"
    else
      "****"
    end
  end
end
