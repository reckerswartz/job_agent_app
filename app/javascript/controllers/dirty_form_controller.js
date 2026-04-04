import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["indicator"]

  connect() {
    this._dirty = false
    this.element.addEventListener("change", () => this._markDirty())
    this.element.addEventListener("input", () => this._markDirty())
  }

  _markDirty() {
    if (!this._dirty) {
      this._dirty = true
      if (this.hasIndicatorTarget) {
        this.indicatorTarget.style.display = ""
      }
    }
  }
}
