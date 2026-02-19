import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["rowsContainer", "template", "row", "destroyField"]

  addRow(event) {
    event.preventDefault()
    const content = this.templateTarget.innerHTML.replace(
      /NEW_RECORD/g,
      new Date().getTime().toString()
    )
    this.rowsContainerTarget.insertAdjacentHTML("beforeend", content)
  }

  removeRow(event) {
    event.preventDefault()
    const row = event.target.closest("[data-nested-form-target='row']")
    const destroyField = row.querySelector("[data-nested-form-target='destroyField']")

    if (destroyField) {
      destroyField.value = "1"
      row.style.display = "none"
    } else {
      row.remove()
    }
  }
}
