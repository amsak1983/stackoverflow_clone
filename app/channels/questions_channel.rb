class QuestionsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "questions"
    logger.info "User #{current_user&.id || 'Anonymous'} subscribed to questions channel"
  end

  def unsubscribed
    logger.info "User #{current_user&.id || 'Anonymous'} unsubscribed from questions channel"
  end
end
