import consumer from "./consumer"

consumer.subscriptions.create("QuestionsChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
    console.log("Connected to QuestionsChannel")
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    // Called when there's incoming data on the websocket for this channel
    if (data.html) {
      if (data.id) {
        // Update existing question
        const questionElement = document.getElementById(`question_${data.id}`)
        if (questionElement) {
          questionElement.outerHTML = data.html
        }
      } else {
        // Add new question
        const questionsList = document.getElementById("questions-list")
        if (questionsList) {
          questionsList.insertAdjacentHTML('afterbegin', data.html)
        }
      }
    } else if (data.action === "remove" && data.id) {
      // Remove question
      const questionElement = document.getElementById(`question_${data.id}`)
      if (questionElement) {
        questionElement.remove()
      }
    }
  }
});
