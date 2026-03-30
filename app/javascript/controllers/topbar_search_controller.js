import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]

  submit(event) {
    if (event.key === "Enter") {
      event.preventDefault()
      const query = this.inputTarget.value.trim()
      if (query.length > 0) {
        window.location.href = `/job_listings?q=${encodeURIComponent(query)}`
      } else {
        window.location.href = "/job_listings"
      }
    }
  }
}
