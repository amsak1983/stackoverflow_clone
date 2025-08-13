import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { questionId: Number }
  static targets = ["list"]

  connect() {
    const questionId = this.questionIdValue
    this.subscription = window.App.cable.subscriptions.create({ channel: "AnswersChannel", question_id: questionId }, {
      received: (data) => {
        if (data.html) {
          const container = this.listTarget || document.getElementById('answers') || this.element
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
