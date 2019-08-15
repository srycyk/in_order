
import Rails from 'rails-ujs';

import DragDropController from "./drag_drop_controller.js"

export default class extends DragDropController {
  update(...args) {
    Rails.ajax(this.ajaxOptions(...this.requestArgs(...args)))
  }

  requestArgs(dragId, dropId, placement) {
    let url = `/in_order/elements/${dragId}`

    let fields = { marker_id: dropId, adjacency: placement }

    let params =  this.params(fields, 'element')

    return [ url, params, 'PUT' ]
  }

  showMessage(message) {
    //document.getElementById("messages").innerHTML = message
  }

  ajaxOptions(url, params, method='POST') {
    let request = { url, params, method }

    return { dataType: "json",
             type: method,
             url: url,
             data: params,
             success: this.handleSuccess(request),
             error: this.handleError(request) }
  }

  params(params, name) {
    return Object.entries(params).map(args => this.param(...args, name)).join('&')
  }
  param(name, value, prefix='') {
    let [leftBracket, rightBracket] = prefix == '' ?  ['', ''] : ['[', ']']

    return `${prefix}${leftBracket}${name}${rightBracket}=${value}`
  }

  handleSuccess(request) {
    return data => this.successful(data, request)
  }

  successful(data, request) {
    this.showMessage(JSON.stringify(request))
  }

  handleError(request) {
    return (...args) => this.unsuccessful(...args, request)
  }

  unsuccessful(response, status, error, request) {
    this.showMessage('<h5>Something went wrong!</h5>')

    console.log(response.responseText)
    console.log(status, error)
    console.log(JSON.stringify(request))
  }
}
