import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["column", "card"]

  dragStart(event) {
    event.dataTransfer.setData("application/drag-id", event.currentTarget.dataset.applicationId)
    event.dataTransfer.effectAllowed = "move"
    event.currentTarget.classList.add("opacity-50")
  }

  dragEnd(event) {
    event.currentTarget.classList.remove("opacity-50")
  }

  dragOver(event) {
    event.preventDefault()
    event.dataTransfer.dropEffect = "move"
    event.currentTarget.closest("[data-pipeline-stage]")?.classList.add("bg-primary", "bg-opacity-10")
  }

  dragLeave(event) {
    event.currentTarget.closest("[data-pipeline-stage]")?.classList.remove("bg-primary", "bg-opacity-10")
  }

  drop(event) {
    event.preventDefault()
    const column = event.currentTarget.closest("[data-pipeline-stage]")
    column?.classList.remove("bg-primary", "bg-opacity-10")

    const applicationId = event.dataTransfer.getData("application/drag-id")
    const newStage = column?.dataset.pipelineStage
    if (!applicationId || !newStage) return

    // Move card visually
    const card = document.querySelector(`[data-application-id="${applicationId}"]`)
    if (card) {
      const cardContainer = column.querySelector("[data-pipeline-board-target='cardContainer']")
      cardContainer?.appendChild(card)
    }

    // Update count badges
    this.updateCounts()

    // PATCH to server
    const csrfToken = document.querySelector("meta[name='csrf-token']")?.content
    fetch(`/job_applications/${applicationId}/update_stage`, {
      method: "PATCH",
      headers: { "Content-Type": "application/json", "X-CSRF-Token": csrfToken },
      body: JSON.stringify({ pipeline_stage: newStage })
    })
  }

  updateCounts() {
    this.columnTargets.forEach(col => {
      const count = col.querySelectorAll("[data-application-id]").length
      const badge = col.querySelector("[data-count]")
      if (badge) badge.textContent = count
    })
  }
}
