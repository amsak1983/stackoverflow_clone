class CommentsChannel < ApplicationCable::Channel
  def subscribed
    question_id = params[:question_id]
    reject unless question_id.present?
    stream_from "questions_#{question_id}_comments"
  end

  def unsubscribed
    stop_all_streams
  end
end
