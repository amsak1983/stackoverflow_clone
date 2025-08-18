# frozen_string_literal: true

class QuestionBroadcaster
  class << self
    def append(question)
      html = ApplicationController.render(
        partial: "questions/question",
        locals: { question: question }
      )

      ActionCable.server.broadcast(
        "questions",
        { html: html }
      )
    end

    def update(question)
      html = ApplicationController.render(
        partial: "questions/question",
        locals: { question: question }
      )

      ActionCable.server.broadcast(
        "questions",
        { html: html, id: question.id }
      )
    end

    def remove(question)
      ActionCable.server.broadcast(
        "questions",
        { id: question.id, action: "remove" }
      )
    end
  end
end
