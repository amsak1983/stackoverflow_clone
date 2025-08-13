import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { questionId: Number }
  static targets = ["list"]

  connect() {
    const questionId = this.questionIdValue
    this.subscription = window.App.cable.subscriptions.create({ channel: "CommentsChannel", question_id: questionId }, {
      received: (data) => {
        if (data.html) {
          const container = this.listTarget || this.element
          container.insertAdjacentHTML('beforeend', data.html)
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
