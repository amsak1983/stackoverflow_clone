import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"

// Connects to data-controller="questions-channel"
export default class extends Controller {
  connect() {
    this.consumer = createConsumer()
    this.subscription = this.consumer.subscriptions.create("QuestionsChannel", {
      connected: () => {
        console.log("Connected to QuestionsChannel")
      },

      disconnected: () => {
        console.log("Disconnected from QuestionsChannel")
      },

      received: (data) => {
        if (data.action === 'create') {
          this.addNewQuestion(data.question)
        }
      }
    })
  }

  disconnect() {
    if (this.subscription) {
      this.subscription.unsubscribe()
    }
    if (this.consumer) {
      this.consumer.disconnect()
    }
  }

  addNewQuestion(questionHtml) {
    const questionsContainer = document.getElementById('questions-list')
    if (questionsContainer) {
      // Create a temporary div to hold the new question HTML
      const tempDiv = document.createElement('div')
      tempDiv.innerHTML = questionHtml
      const newQuestionElement = tempDiv.firstElementChild

      // Add the new question at the top of the list
      questionsContainer.insertBefore(newQuestionElement, questionsContainer.firstChild)
      
      // Add a subtle animation to highlight the new question
      newQuestionElement.classList.add('bg-green-50', 'border-green-200')
      setTimeout(() => {
        newQuestionElement.classList.remove('bg-green-50', 'border-green-200')
      }, 3000)
    }
  }
}
