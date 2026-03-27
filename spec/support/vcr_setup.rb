require "vcr"

VCR.configure do |config|
  config.cassette_library_dir = "spec/cassettes"
  config.hook_into :webmock
  config.ignore_localhost = true
  config.configure_rspec_metadata!
  config.filter_sensitive_data("<API_KEY>") { ENV["TAVILY_API_KEY"] }
  config.filter_sensitive_data("<FIGMA_KEY>") { ENV["FIGMA_API_KEY"] }
  config.filter_sensitive_data("<MIRO_TOKEN>") { ENV["MIRO_OAUTH_TOKEN"] }
  config.default_cassette_options = {
    record: :new_episodes,
    match_requests_on: [:method, :uri, :body]
  }
end
