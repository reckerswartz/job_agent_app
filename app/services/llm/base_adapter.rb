module Llm
  class BaseAdapter
    def initialize(provider)
      @provider = provider
    end

    def chat(messages, model:)
      raise NotImplementedError, "#{self.class}#chat must be implemented"
    end

    def vision(image_data, prompt:, model:)
      raise NotImplementedError, "#{self.class}#vision must be implemented"
    end

    protected

    attr_reader :provider

    def api_key
      provider.api_key
    end

    def http_post(url, body, headers = {})
      uri = URI(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"
      http.read_timeout = 120
      http.open_timeout = 30

      request = Net::HTTP::Post.new(uri.path, default_headers.merge(headers))
      request.body = body.to_json

      start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      response = http.request(request)
      latency_ms = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - start_time) * 1000).to_i

      { status: response.code.to_i, body: JSON.parse(response.body), latency_ms: latency_ms }
    rescue JSON::ParserError
      { status: response&.code.to_i || 0, body: { "error" => response&.body }, latency_ms: latency_ms || 0 }
    rescue => e
      { status: 0, body: { "error" => e.message }, latency_ms: 0 }
    end

    def default_headers
      { "Content-Type" => "application/json" }
    end
  end
end
