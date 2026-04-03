import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sidebar", "overlay"]

  connect() {
    // Close sidebar when any nav link is clicked on mobile
    this.sidebarTarget.querySelectorAll(".sidebar__link").forEach(link => {
      link.addEventListener("click", () => {
        if (window.innerWidth < 992) this.close()
      })
    })

    // Swipe-to-close: track touch gestures on sidebar
    this._touchStartX = 0
    this._touchCurrentX = 0

    this.sidebarTarget.addEventListener("touchstart", (e) => {
      this._touchStartX = e.touches[0].clientX
    }, { passive: true })

    this.sidebarTarget.addEventListener("touchmove", (e) => {
      this._touchCurrentX = e.touches[0].clientX
    }, { passive: true })

    this.sidebarTarget.addEventListener("touchend", () => {
      const swipeDistance = this._touchStartX - this._touchCurrentX
      if (swipeDistance > 60) this.close() // Swipe left → close
    })
  }

  toggle() {
    this.sidebarTarget.classList.toggle("sidebar--open")
    this.overlayTarget.classList.toggle("sidebar-overlay--visible")
  }

  close() {
    this.sidebarTarget.classList.remove("sidebar--open")
    this.overlayTarget.classList.remove("sidebar-overlay--visible")
  }
}
