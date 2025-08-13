import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"

// Connects to data-controller="comments-channel"
export default class extends Controller {
  static values = { questionId: Number }

  connect() {
    if (this.questionIdValue) {
      this.consumer = createConsumer()
      this.subscription = this.consumer.subscriptions.create(
        { channel: "CommentsChannel", question_id: this.questionIdValue },
        {
          connected: () => {
            console.log(`Connected to CommentsChannel for question ${this.questionIdValue}`)
          },

          disconnected: () => {
            console.log(`Disconnected from CommentsChannel for question ${this.questionIdValue}`)
          },

          received: (data) => {
            if (data.action === 'create') {
              this.addNewComment(data.comment, data.commentable_type, data.commentable_id)
            } else if (data.action === 'destroy') {
              this.removeComment(data.comment_id)
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

  addNewComment(commentHtml, commentableType, commentableId) {
    const commentsContainer = document.getElementById(`comments_list_${commentableType}_${commentableId}`)
    if (commentsContainer) {
      // Create a temporary div to hold the new comment HTML
      const tempDiv = document.createElement('div')
      tempDiv.innerHTML = commentHtml
      const newCommentElement = tempDiv.firstElementChild

      // Add the new comment at the top of the list (newest first)
      commentsContainer.insertBefore(newCommentElement, commentsContainer.firstChild)
      
      // Add a subtle animation to highlight the new comment
      newCommentElement.classList.add('bg-green-50', 'border-green-200')
      setTimeout(() => {
        newCommentElement.classList.remove('bg-green-50', 'border-green-200')
      }, 3000)

      // Update comments count
      this.updateCommentsCount(commentableType, commentableId, 1)
    }
  }

  removeComment(commentId) {
    const commentElement = document.getElementById(`comment_${commentId}`)
    if (commentElement) {
      // Find the commentable info from the comment's container
      const commentsSection = commentElement.closest('[id^="comments_"]')
      if (commentsSection) {
        const matches = commentsSection.id.match(/comments_(\w+)_(\d+)/)
        if (matches) {
          const commentableType = matches[1]
          const commentableId = matches[2]
          
          // Remove the comment element
          commentElement.remove()
          
          // Update comments count
          this.updateCommentsCount(commentableType, commentableId, -1)
        }
      }
    }
  }

  updateCommentsCount(commentableType, commentableId, change) {
    const countElement = document.getElementById(`comments_count_${commentableType}_${commentableId}`)
    if (countElement) {
      const currentCount = parseInt(countElement.textContent) || 0
      countElement.textContent = Math.max(0, currentCount + change)
    }
  }
}
