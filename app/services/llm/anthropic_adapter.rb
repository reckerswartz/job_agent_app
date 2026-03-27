module Llm
  class AnthropicAdapter < BaseAdapter
    def chat(messages, model:)
      url = "#{provider.base_url}/messages"
      system_msg = messages.find { |m| m[:role] == "system" || m["role"] == "system" }
      user_msgs = messages.reject { |m| (m[:role] || m["role"]) == "system" }

      body = {
        model: model.identifier,
        max_tokens: model.settings["max_tokens"] || 4096,
        messages: user_msgs.map { |m| { role: m[:role] || m["role"], content: m[:content] || m["content"] } }
      }
      body[:system] = system_msg[:content] || system_msg["content"] if system_msg

      result = http_post(url, body)

      if result[:status] == 200
        content = result[:body].dig("content", 0, "text")
        usage = result[:body]["usage"] || {}
        {
          content: content,
          token_usage: {
            prompt_tokens: usage["input_tokens"],
            completion_tokens: usage["output_tokens"],
            total_tokens: (usage["input_tokens"].to_i + usage["output_tokens"].to_i)
          },
          latency_ms: result[:latency_ms]
        }
      else
        error_msg = result[:body].dig("error", "message") || result[:body].to_s
        raise StandardError, "Anthropic API error (#{result[:status]}): #{error_msg}"
      end
    end

    def vision(image_data, prompt:, model:)
      messages = [
        {
          role: "user",
          content: [
            { type: "text", text: prompt },
            { type: "image", source: { type: "base64", media_type: "image/jpeg", data: image_data } }
          ]
        }
      ]
      chat(messages, model: model)
    end

    protected

    def default_headers
      super.merge(
        "x-api-key" => api_key,
        "anthropic-version" => "2023-06-01"
      )
    end
  end
end
