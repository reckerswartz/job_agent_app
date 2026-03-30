import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["icon"]

  connect() {
    const saved = localStorage.getItem("theme") || "light"
    this.applyTheme(saved)
  }

  toggle() {
    const current = document.documentElement.getAttribute("data-theme") || "light"
    const next = current === "dark" ? "light" : "dark"
    this.applyTheme(next)
    localStorage.setItem("theme", next)
  }

  applyTheme(theme) {
    document.documentElement.setAttribute("data-theme", theme)
    if (this.hasIconTarget) {
      this.iconTarget.textContent = theme === "dark" ? "☀️" : "🌙"
    }
  }
}
