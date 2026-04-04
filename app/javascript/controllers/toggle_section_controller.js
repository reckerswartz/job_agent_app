import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { showFor: String, watch: String }

  connect() {
    this._watchEl = document.getElementById(this.watchValue)
    if (this._watchEl) {
      this._onChange = () => this._toggle()
      this._watchEl.addEventListener("change", this._onChange)
      this._toggle()
    }
  }

  disconnect() {
    if (this._watchEl) {
      this._watchEl.removeEventListener("change", this._onChange)
    }
  }

  _toggle() {
    const allowed = this.showForValue.split(",").map(s => s.trim())
    const selected = this._watchEl.value
    this.element.style.display = allowed.includes(selected) ? "" : "none"
  }
}
