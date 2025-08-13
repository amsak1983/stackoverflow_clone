class CommentsChannel < ApplicationCable::Channel
  def subscribed
    reject unless params[:question_id].present?
    stream_from "questions/#{params[:question_id]}/comments"
  end
end 
