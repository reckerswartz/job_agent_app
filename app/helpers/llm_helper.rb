module LlmHelper
  def llm_available?
    LlmProvider.active.any?(&:available?)
  end
end
