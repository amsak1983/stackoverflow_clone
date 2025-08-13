class AnswersChannel < ApplicationCable::Channel
  def subscribed
    reject unless params[:question_id].present?
    stream_from "questions/#{params[:question_id]}/answers"
  end
end 
