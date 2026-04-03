import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["searchInput", "perPage"]

  search() {
    clearTimeout(this._searchTimeout)
    this._searchTimeout = setTimeout(() => {
      this.reload()
    }, 350)
  }

  sort(event) {
    event.preventDefault()
    const url = event.currentTarget.getAttribute("href")
    if (url) Turbo.visit(url, { frame: "_top" })
  }

  changePerPage() {
    this.reload()
  }

  reload() {
    const url = new URL(window.location.href)

    if (this.hasSearchInputTarget) {
      const q = this.searchInputTarget.value.trim()
      if (q) { url.searchParams.set("q", q) } else { url.searchParams.delete("q") }
    }

    if (this.hasPerPageTarget) {
      url.searchParams.set("per", this.perPageTarget.value)
    }

    url.searchParams.delete("page")
    Turbo.visit(url.toString(), { frame: "_top" })
  }
}
