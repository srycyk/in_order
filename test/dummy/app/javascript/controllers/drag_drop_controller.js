
import { Controller } from "stimulus"

export default class extends Controller {
  static draggedIdKeyName = "in-order/draggged-id"

  static dataId = "data-element-id"

  dragstart(event) {
    let itemId = event.target.getAttribute(this.constructor.dataId)

    event.dataTransfer.setData(this.constructor.draggedIdKeyName, itemId)

    event.dataTransfer.effectAllowed = "move"
  }

  dragover(event) {
    event.preventDefault()

    return true
  }

  dragenter(event) {
    event.preventDefault()
  }

  drop(event) {
    const dropppedElement = event.target

    const draggedElement = this.getDraggedElement(event.dataTransfer)

    let placement = this.dropOffAt(draggedElement, dropppedElement)

    let dragId = draggedElement.getAttribute(this.constructor.dataId)
    let dropId = dropppedElement.getAttribute(this.constructor.dataId)

    if (placement) {
      let at = placement == 'before' ? 'beforebegin' : 'afterend'

      dropppedElement.insertAdjacentElement(at, draggedElement)

      this.update(dragId, dropId, placement)
    }

    event.preventDefault()
  }

  dragend(event) {
  }

  getDraggedElement(dataStore) {
    let itemId = dataStore.getData(this.constructor.draggedIdKeyName)

    let selector = `[${this.constructor.dataId}='${itemId}']`

    return this.element.querySelector(selector)
  }

  dropOffAt(draggedItem, dropTarget) {
    const positionComparison = dropTarget.compareDocumentPosition(draggedItem)

    if (positionComparison & 4)
      return 'before'
    else if (positionComparison & 2)
      return 'after'
    else
      return null
  }

  // To be overridden
  update(dragId, dropId, placement) {
    console.log(dragId, dropId, placement)
  }
}
