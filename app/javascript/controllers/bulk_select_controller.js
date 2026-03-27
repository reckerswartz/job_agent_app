import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox", "selectAll", "actionBar", "count", "idsField"]

  connect() {
    this.updateUI()
  }

  toggleAll() {
    const checked = this.selectAllTarget.checked
    this.checkboxTargets.forEach(cb => cb.checked = checked)
    this.updateUI()
  }

  toggle() {
    this.updateUI()
  }

  updateUI() {
    const selected = this.selectedIds()
    const count = selected.length

    if (this.hasActionBarTarget) {
      this.actionBarTarget.style.display = count > 0 ? "flex" : "none"
    }
    if (this.hasCountTarget) {
      this.countTarget.textContent = `${count} selected`
    }
    if (this.hasSelectAllTarget) {
      this.selectAllTarget.checked = count > 0 && count === this.checkboxTargets.length
    }
  }

  submitBulk(event) {
    const status = event.currentTarget.dataset.status
    const ids = this.selectedIds()
    if (ids.length === 0) return

    const form = document.createElement("form")
    form.method = "POST"
    form.action = "/job_listings/bulk_update"

    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content
    if (csrfToken) {
      const tokenInput = document.createElement("input")
      tokenInput.type = "hidden"
      tokenInput.name = "authenticity_token"
      tokenInput.value = csrfToken
      form.appendChild(tokenInput)
    }

    const statusInput = document.createElement("input")
    statusInput.type = "hidden"
    statusInput.name = "new_status"
    statusInput.value = status
    form.appendChild(statusInput)

    ids.forEach(id => {
      const input = document.createElement("input")
      input.type = "hidden"
      input.name = "ids[]"
      input.value = id
      form.appendChild(input)
    })

    document.body.appendChild(form)
    form.submit()
  }

  selectedIds() {
    return this.checkboxTargets.filter(cb => cb.checked).map(cb => cb.value)
  }
}
