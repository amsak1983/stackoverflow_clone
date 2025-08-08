// Stimulus controller for handling voting functionality
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["rating"]

  connect() {
    console.log("Votes controller connected")
  }

  /**
   * Handle vote action
   * @param {Event} event - The click event
   */
  vote(event) {
    event.preventDefault()
    
    const form = event.target.closest("form")
    const url = form.action
    
    this._sendVoteRequest(url, {
      method: "POST"
    })
  }

  /**
   * Handle cancel vote action
   * @param {Event} event - The click event
   */
  cancelVote(event) {
    event.preventDefault()
    
    const form = event.target.closest("form")
    const url = form.action
    
    this._sendVoteRequest(url, {
      method: "DELETE"
    })
  }

  /**
   * Send AJAX request for voting actions
   * @param {string} url - The request URL
   * @param {Object} options - Fetch options
   * @private
   */
  async _sendVoteRequest(url, options) {
    try {
      const response = await fetch(url, {
        ...options,
        headers: {
          "X-Requested-With": "XMLHttpRequest",
          "Accept": "application/json"
        }
      })
      
      if (!response.ok) {
        throw new Error(`HTTP error! Status: ${response.status}`)
      }
      
      const data = await response.json()
      this._updateVotingUI(data)
    } catch (error) {
      console.error("Error processing vote:", error)
    }
  }

  /**
   * Update the UI with new voting data
   * @param {Object} data - Response data containing rating and user_vote
   * @private
   */
  _updateVotingUI(data) {
    // Find the closest votable container
    const votableContainer = this.element
    
    // Update rating display
    const ratingElement = votableContainer.querySelector("[data-votes-target='rating']")
    if (ratingElement) {
      ratingElement.textContent = data.rating
    }
    
    // Update button styles based on user's vote
    const upvoteButton = votableContainer.querySelector(".vote-up")
    const downvoteButton = votableContainer.querySelector(".vote-down")
    
    if (upvoteButton && downvoteButton) {
      // Reset styles
      upvoteButton.classList.remove("text-green-600")
      upvoteButton.classList.add("text-gray-600", "hover:text-green-600")
      downvoteButton.classList.remove("text-red-600")
      downvoteButton.classList.add("text-gray-600", "hover:text-red-600")
      
      // Apply active style based on user's vote
      if (data.user_vote === 1) {
        upvoteButton.classList.remove("text-gray-600", "hover:text-green-600")
        upvoteButton.classList.add("text-green-600")
      } else if (data.user_vote === -1) {
        downvoteButton.classList.remove("text-gray-600", "hover:text-red-600")
        downvoteButton.classList.add("text-red-600")
      }
    }
    
    // Toggle cancel button visibility
    const cancelContainer = votableContainer.querySelector(".cancel-vote-container")
    if (cancelContainer) {
      if (data.user_vote) {
        cancelContainer.classList.remove("hidden")
      } else {
        cancelContainer.classList.add("hidden")
      }
    }
  }
}
