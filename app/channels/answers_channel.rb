class AnswersChannel < ApplicationCable::Channel
  def subscribed
    reject unless params[:question_id].present?
    stream_from "questions/#{params[:question_id]}/answers"
    logger.info "User #{current_user&.id || 'Anonymous'} subscribed to answers channel for question #{params[:question_id]}"
  end

  def unsubscribed
    logger.info "User #{current_user&.id || 'Anonymous'} unsubscribed from answers channel for question #{params[:question_id]}"
  end
end
