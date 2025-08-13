import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"

// Connects to data-controller="answers-channel"
export default class extends Controller {
  static values = { questionId: Number }

  connect() {
    if (this.questionIdValue) {
      this.consumer = createConsumer()
      this.subscription = this.consumer.subscriptions.create(
        { channel: "AnswersChannel", question_id: this.questionIdValue },
        {
          connected: () => {
            console.log(`Connected to AnswersChannel for question ${this.questionIdValue}`)
          },

          disconnected: () => {
            console.log(`Disconnected from AnswersChannel for question ${this.questionIdValue}`)
          },

          received: (data) => {
            if (data.action === 'create') {
              this.addNewAnswer(data.answer)
            }
          }
        }
      )
    }
  }

  disconnect() {
    if (this.subscription) {
      this.subscription.unsubscribe()
    }
    if (this.consumer) {
      this.consumer.disconnect()
    }
  }

  addNewAnswer(answerHtml) {
    const answersContainer = document.getElementById('answers-list')
    if (answersContainer) {
      // Create a temporary div to hold the new answer HTML
      const tempDiv = document.createElement('div')
      tempDiv.innerHTML = answerHtml
      const newAnswerElement = tempDiv.firstElementChild

      // Add the new answer at the bottom of the list
      answersContainer.appendChild(newAnswerElement)
      
      // Add a subtle animation to highlight the new answer
      newAnswerElement.classList.add('bg-green-50', 'border-green-200')
      setTimeout(() => {
        newAnswerElement.classList.remove('bg-green-50', 'border-green-200')
      }, 3000)

      // Update answers count if element exists
      const answersCount = document.getElementById('answers-count')
      if (answersCount) {
        const currentCount = parseInt(answersCount.textContent) || 0
        answersCount.textContent = currentCount + 1
      }

      // Scroll to the new answer
      newAnswerElement.scrollIntoView({ behavior: 'smooth', block: 'nearest' })
    }
  }
}
