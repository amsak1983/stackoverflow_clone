class CommentsController < ApplicationController
  include ErrorHandling
  before_action :authenticate_user!
  before_action :set_commentable, except: :destroy
  before_action :set_comment, only: :destroy
  before_action :authorize_destroy!, only: :destroy

  def create
    @comment = @commentable.comments.new(comment_params.merge(user: current_user))

    respond_to do |format|
      if @comment.save
        # Broadcast the newly created comment to subscribers
        CommentBroadcaster.append(@comment)
        format.html { redirect_to question_path(question_for(@commentable)), notice: "Comment added" }
        format.turbo_stream { render :create, status: :created }
      else
        format.html do
          flash.now[:alert] = @comment.errors.full_messages.to_sentence
          render "questions/show", status: :unprocessable_entity
        end
        format.turbo_stream { render :create, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @comment.destroy
    # Broadcast removal to subscribers
    CommentBroadcaster.remove(@comment)
    respond_to do |format|
      format.html { redirect_to question_path(question_for(@commentable)), notice: "Comment deleted" }
      format.turbo_stream { head :ok }
    end
  end

  private

  def set_commentable
    if params[:question_id]
      @commentable = Question.find_by(id: params[:question_id])
      handle_record_not_found("Question") and return unless @commentable
    elsif params[:answer_id]
      @commentable = Answer.find_by(id: params[:answer_id])
      handle_record_not_found("Answer") and return unless @commentable
    else
      head :unprocessable_entity
    end
  end

  def set_comment
    @comment = Comment.find_by(id: params[:id])
    handle_record_not_found("Comment") and return unless @comment
    @commentable = @comment.commentable
  end

  def authorize_destroy!
    head :forbidden unless current_user&.author_of?(@comment)
  end

  def question_for(record)
    record.is_a?(Question) ? record : record.question
  end

  def comment_params
    params.require(:comment).permit(:body)
  end
end
