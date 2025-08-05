import { Controller } from "@hotwired/stimulus"

// Controller for processing links to GitHub Gists
export default class extends Controller {
  static targets = ["gist"]
  
  connect() {
    // When the controller is connected, check for gist targets
    if (this.hasGistTarget) {
      this.loadGists()
    }
  }
  
  // Loads gist scripts and processes their contents
  loadGists() {
    this.gistTargets.forEach(gistTarget => {
      const gistId = gistTarget.id.split('-')[1]
      if (gistId) {
        // Check if this gist has already been loaded
        if (!gistTarget.hasAttribute('data-loaded')) {
          this.loadGistContent(gistId, gistTarget)
          gistTarget.setAttribute('data-loaded', 'true')
        }
      }
    })
  }
  
  // Loads gist content by ID
  loadGistContent(gistId, target) {
    const script = document.createElement('script')
    script.src = `https://gist.github.com/${gistId}.js`
    script.onload = () => {
      // Processing a successful gist download
      console.log(`Gist ${gistId} loaded successfully`)
    }
    script.onerror = () => {
      // Handling gist loading error
      console.error(`Error loading Gist ${gistId}`)
      target.innerHTML = `<p class="text-red-500">Failed to load Gist. <a href="https://gist.github.com/${gistId}" target="_blank" class="text-blue-600 hover:text-blue-800">Open on GitHub</a></p>`
    }
    
    target.appendChild(script)
  }
}
