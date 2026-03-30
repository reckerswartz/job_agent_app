import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { delay: { type: Number, default: 5000 } }

  connect() {
    this.element.classList.add("toast-notification--enter")
    requestAnimationFrame(() => {
      this.element.classList.add("toast-notification--visible")
    })
    this.timeout = setTimeout(() => this.dismiss(), this.delayValue)
  }

  disconnect() {
    if (this.timeout) clearTimeout(this.timeout)
  }

  dismiss() {
    this.element.classList.remove("toast-notification--visible")
    this.element.classList.add("toast-notification--exit")
    setTimeout(() => this.element.remove(), 300)
  }
}
