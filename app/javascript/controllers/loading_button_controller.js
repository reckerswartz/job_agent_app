import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { text: { type: String, default: "Processing..." } }

  submit() {
    const btn = this.element.querySelector("button[type='submit'], input[type='submit'], button:not([type])")
    if (!btn) return

    btn.disabled = true
    btn.dataset.originalText = btn.textContent
    btn.innerHTML = `<span class="spinner-border spinner-border-sm me-1" role="status"></span> ${this.textValue}`
  }
}
