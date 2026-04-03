class LlmModelVerifyJob < ApplicationJob
  queue_as :default

  VERIFY_PROMPT = "Reply with exactly: OK"

  def perform(llm_model_id)
    model = LlmModel.find(llm_model_id)
    provider = model.llm_provider
    return unless model.active? && provider.available?

    adapter = Llm::NvidiaAdapter.new(provider)
    verification = model.llm_verifications.create!(
      status: "pending",
      input_payload: VERIFY_PROMPT
    )

    start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    result = adapter.chat([{ role: "user", content: VERIFY_PROMPT }], model: model)
    latency = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - start_time) * 1000).to_i

    verification.update!(
      status: "ok",
      response_payload: result[:content].to_s.truncate(1000),
      latency_ms: latency
    )
    model.update!(verification_status: "ok", last_verified_at: Time.current)

  rescue => e
    err_status = e.message.include?("timeout") ? "timeout" : "failed"
    verification&.update!(
      status: err_status,
      error_message: e.message.truncate(500),
      latency_ms: latency
    )
    model.update!(verification_status: err_status, last_verified_at: Time.current)
    Rails.logger.error("[LlmModelVerifyJob] #{model.identifier}: #{e.message}")
  end
end
