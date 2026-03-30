import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal"]

  connect() {
    this.buffer = ""
    this.bufferTimeout = null
    this.handleKeydown = this.handleKeydown.bind(this)
    document.addEventListener("keydown", this.handleKeydown)
  }

  disconnect() {
    document.removeEventListener("keydown", this.handleKeydown)
  }

  handleKeydown(event) {
    // Ignore if user is typing in an input/textarea
    const tag = event.target.tagName.toLowerCase()
    if (tag === "input" || tag === "textarea" || tag === "select") return

    const key = event.key.toLowerCase()

    if (key === "?") {
      event.preventDefault()
      this.toggleHelp()
      return
    }

    // Buffer keys for two-key shortcuts (g + letter)
    clearTimeout(this.bufferTimeout)
    this.buffer += key
    this.bufferTimeout = setTimeout(() => { this.buffer = "" }, 500)

    if (this.buffer === "gd") { window.location.href = "/dashboard"; return }
    if (this.buffer === "gs") { window.location.href = "/job_sources"; return }
    if (this.buffer === "gl") { window.location.href = "/job_listings"; return }
    if (this.buffer === "ga") { window.location.href = "/job_applications"; return }
    if (this.buffer === "gp") { window.location.href = "/profile"; return }
    if (this.buffer === "gi") { window.location.href = "/interventions"; return }
    if (this.buffer === "ge") { window.location.href = "/settings/edit"; return }
  }

  toggleHelp() {
    if (this.hasModalTarget) {
      const modal = this.modalTarget
      if (modal.style.display === "block") {
        modal.style.display = "none"
      } else {
        modal.style.display = "block"
      }
    }
  }

  closeHelp() {
    if (this.hasModalTarget) {
      this.modalTarget.style.display = "none"
    }
  }
}
