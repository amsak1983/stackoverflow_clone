import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { questionId: Number }
  static targets = ["list"]

  connect() {
    const questionId = this.questionIdValue
    if (!questionId) {
      console.error("No questionId provided for answers channel")
      return
    }

    this.subscription = window.App.cable.subscriptions.create({ channel: "AnswersChannel", question_id: questionId }, {
      connected: () => {
        console.log(`Connected to AnswersChannel for question ${questionId}`)
      },
      disconnected: () => {
        console.log(`Disconnected from AnswersChannel for question ${questionId}`)
      },
      received: (data) => {
        console.log("Received answer data:", data)
        if (data.html) {
          const container = this.listTarget || document.getElementById('answers') || this.element
          if (container) {
            container.insertAdjacentHTML('beforeend', data.html)
          } else {
            console.error("Could not find answers container")
          }
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
