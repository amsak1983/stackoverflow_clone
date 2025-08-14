import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { questionId: Number }
  static targets = ["list"]

  connect() {
    const questionId = this.questionIdValue
    if (!questionId) {
      console.error("No questionId provided for comments channel")
      return
    }

    this.subscription = window.App.cable.subscriptions.create(
      { 
        channel: "CommentsChannel", 
        question_id: questionId.toString() 
      },
      {
        connected: () => {
          console.log(`Connected to comments channel for question ${questionId}`)
        },
        disconnected: () => {
          console.log(`Disconnected from comments channel for question ${questionId}`)
        },
        received: (data) => {
          console.log("Received comment data:", data)
          if (data.html) {
            let container = this.listTarget
            if (data.commentable_type === 'Answer') {
              container = document.getElementById(`answer-${data.commentable_id}-comments`)
            } else if (data.commentable_type === 'Question') {
              container = document.getElementById(`question-${questionId}-comments`)
            }
            
            if (container) {
              container.insertAdjacentHTML('beforeend', data.html)
              // Scroll to the new comment
              const newComment = container.lastElementChild
              if (newComment) {
                newComment.scrollIntoView({ behavior: 'smooth', block: 'nearest' })
              }
            } else {
              console.error("Could not find container for comment:", data)
            }
          }
        }
      }
    )
  }

  disconnect() {
    if (this.subscription) {
      this.subscription.unsubscribe()
      this.subscription = null
    }
  }
}
