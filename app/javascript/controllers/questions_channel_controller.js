import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["list"]

  connect() {
    this.subscription = window.App.cable.subscriptions.create({ channel: "QuestionsChannel" }, {
      received: (data) => {
        if (data.html) {
          const container = this.listTarget || this.element
          container.insertAdjacentHTML('afterbegin', data.html)
        }
      }
    })
  }

  disconnect() {
    if (this.subscription) {
      this.subscription.unsubscribe()
    }
  }
} 
