import { Controller } from "@hotwired/stimulus"

// This is a Stimulus adapter for Cocoon to work with Turbo
export default class extends Controller {
  connect() {
    // When controller connects, initialize events
    this.setupCocoonEvents()
  }

  setupCocoonEvents() {
    // Make sure all events are properly delegated for Turbo compatibility
    document.addEventListener('click', (event) => {
      // Check if this click is targeting a cocoon add button
      const addButton = event.target.closest('.add_fields')
      if (addButton && this.element.contains(addButton)) {
        // Handle the button click, no need for preventDefault 
        // since cocoon.js will handle that
        console.log('Cocoon add button clicked:', addButton)
      }
    })
  }
  
  // This is added for direct controller action binding
  addAssociation(event) {
    console.log('Add association called through stimulus')
    // Let cocoon.js do its job, we just need to make sure
    // the event propagates
  }
}
