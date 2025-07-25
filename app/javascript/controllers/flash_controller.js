import { Controller } from "@hotwired/stimulus"

// Manages flash messages with auto-dismiss functionality
export default class extends Controller {
  connect() {
    // Auto-dismiss flash messages after 5 seconds
    this.timeout = setTimeout(() => {
      this.dismiss()
    }, 5000)
  }

  // Dismiss the flash message
  dismiss() {
    this.element.style.opacity = '0'
    // Wait for the fade out transition to complete before removing the element
    setTimeout(() => {
      this.element.remove()
      // If there are no more flash messages, remove the container
      if (document.getElementById('flash-messages')?.children.length === 0) {
        document.getElementById('flash-messages')?.remove()
      }
    }, 300)
  }

  // Clean up the timeout when the controller is disconnected
  disconnect() {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
  }
}
