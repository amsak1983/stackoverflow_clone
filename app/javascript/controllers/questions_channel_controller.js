import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["list"]

  connect() {
    this.subscription = window.App.cable.subscriptions.create({ channel: "QuestionsChannel" }, {
      connected: () => {
        console.log("Connected to QuestionsChannel")
      },
      disconnected: () => {
        console.log("Disconnected from QuestionsChannel")
      },
      received: (data) => {
        console.log("Received question data:", data)
        if (data.html) {
          const container = document.getElementById('questions') || this.listTarget || this.element
          if (container) {
            container.insertAdjacentHTML('afterbegin', data.html)
          } else {
            console.error("Could not find questions container")
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
