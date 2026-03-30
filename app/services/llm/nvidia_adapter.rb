module Llm
  class NvidiaAdapter < BaseAdapter
    def chat(messages, model:)
      url = "#{provider.base_url}/chat/completions"
      body = {
        model: model.identifier,
        messages: messages,
        max_tokens: model.settings["max_tokens"] || 4096,
        temperature: model.settings["temperature"] || 0.7,
        stream: false
      }

      result = http_post(url, body)

      if result[:status] == 200
        choice = result[:body].dig("choices", 0, "message", "content")
        usage = result[:body]["usage"] || {}
        {
          content: choice,
          token_usage: {
            prompt_tokens: usage["prompt_tokens"],
            completion_tokens: usage["completion_tokens"],
            total_tokens: usage["total_tokens"]
          },
          latency_ms: result[:latency_ms]
        }
      else
        error_msg = result[:body].dig("error", "message") || result[:body].dig("detail") || result[:body].to_s
        raise StandardError, "NVIDIA API error (#{result[:status]}): #{error_msg}"
      end
    end

    def vision(image_data, prompt:, model:)
      messages = [
        {
          role: "user",
          content: [
            { type: "text", text: prompt },
            { type: "image_url", image_url: { url: image_data } }
          ]
        }
      ]
      chat(messages, model: model)
    end

    def multi_vision(images, prompt:, model:)
      content = [ { type: "text", text: prompt } ]
      images.each do |img|
        content << { type: "image_url", image_url: { url: img } }
      end
      messages = [ { role: "user", content: content } ]
      chat(messages, model: model)
    end

    protected

    def default_headers
      super.merge("Authorization" => "Bearer #{api_key}")
    end
  end
end
