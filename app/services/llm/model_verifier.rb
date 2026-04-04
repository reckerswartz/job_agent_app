module Llm
  class ModelVerifier
    VERIFY_PROMPT = "Reply with exactly: OK"

    def initialize(provider)
      @provider = provider
      @adapter = NvidiaAdapter.new(provider)
    end

    def verify(model)
      return { status: "skipped", message: "Model inactive" } unless model.active?
      return { status: "skipped", message: "Provider unavailable" } unless provider.available?

      messages = [ { role: "user", content: VERIFY_PROMPT } ]

      start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      result = adapter.chat(messages, model: model)
      latency = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - start_time) * 1000).to_i

      model.update!(
        verification_status: "ok",
        last_verified_at: Time.current
      )

      { status: "ok", latency_ms: latency, response: result[:content].to_s.truncate(100) }
    rescue => e
      status = e.message.include?("timeout") ? "timeout" : "failed"
      model.update!(
        verification_status: status,
        last_verified_at: Time.current
      )

      { status: status, error: e.message.truncate(200) }
    end

    def verify_all
      results = {}
      provider.llm_models.active.find_each do |model|
        results[model.identifier] = verify(model)
        sleep(0.5) # Rate limit between verification calls
      end
      results
    end

    private

    attr_reader :provider, :adapter
  end
end
