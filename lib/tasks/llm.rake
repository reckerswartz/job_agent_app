namespace :llm do
  desc "Sync models from NVIDIA API"
  task sync: :environment do
    provider = LlmProvider.active.first
    unless provider&.available?
      puts "No active provider with API key. Set NVIDIA_API_KEY in Settings first."
      exit 1
    end

    puts "Syncing models from #{provider.name} (#{provider.base_url})..."
    result = Llm::ModelSyncService.new(provider).sync!

    if result[:error]
      puts "ERROR: #{result[:error]}"
    else
      puts "Done! #{result[:total]} models (#{result[:added]} new, #{result[:updated]} updated, #{result[:deactivated]} deactivated)"
    end
  end

  desc "Verify all active LLM models respond correctly"
  task verify: :environment do
    provider = LlmProvider.active.first
    unless provider&.available?
      puts "No active provider with API key."
      exit 1
    end

    puts "Verifying #{provider.llm_models.active.count} active models..."
    results = Llm::ModelVerifier.new(provider).verify_all

    results.each do |identifier, result|
      status = result[:status]
      icon = status == "ok" ? "+" : "x"
      detail = status == "ok" ? "#{result[:latency_ms]}ms" : result[:error].to_s.truncate(80)
      puts "  [#{icon}] #{identifier}: #{status} (#{detail})"
    end

    ok = results.values.count { |r| r[:status] == "ok" }
    puts "\n#{ok}/#{results.size} models OK"
  end

  desc "Quick test: send a message to the primary text model"
  task test: :environment do
    provider = LlmProvider.active.first
    unless provider&.available?
      puts "No active provider with API key."
      exit 1
    end

    model = provider.default_text_model
    unless model
      puts "No active text model found. Run `rails llm:sync` first."
      exit 1
    end

    puts "Testing #{model.name} (#{model.identifier})..."
    adapter = Llm::NvidiaAdapter.new(provider)
    messages = [ { role: "user", content: "Reply with: Hello from Job Agent" } ]

    begin
      result = adapter.chat(messages, model: model)
      puts "Response: #{result[:content]}"
      puts "Tokens: #{result[:token_usage]}"
      puts "Latency: #{result[:latency_ms]}ms"
    rescue => e
      puts "ERROR: #{e.message}"
    end
  end
end
