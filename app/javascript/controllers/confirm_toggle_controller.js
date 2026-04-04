import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox"]
  static values = { message: String }

  confirm(event) {
    const checkbox = this.checkboxTarget
    if (checkbox.checked && this.messageValue) {
      if (!window.confirm(this.messageValue)) {
        event.preventDefault()
        checkbox.checked = false
      }
    }
  }
}
