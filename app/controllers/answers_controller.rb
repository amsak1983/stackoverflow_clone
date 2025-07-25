class AnswersController < ApplicationController
  include ErrorHandling
  before_action :authenticate_user!
  before_action :set_question, only: [:create]
  before_action :set_answer, only: [:edit, :update, :destroy, :mark_as_best]
  before_action :authorize_user!, only: [:update, :destroy]
  before_action :authorize_question_author!, only: [:mark_as_best]

  # POST /questions/:question_id/answers
  def create
    @answer = @question.answers.new(answer_params)
    @answer.user = current_user

    respond_to do |format|
      if @answer.save
        format.turbo_stream
        format.html { redirect_to @question, notice: "Answer was successfully created" }
        format.json { render json: @answer, status: :created, location: @question }
      else
        @answers = @question.answers.sorted_by_best
        format.turbo_stream { render :new, status: :unprocessable_entity }
        format.html { render "questions/show", status: :unprocessable_entity }
        format.json { render json: @answer.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /answers/:id/edit
  def edit
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @answer.question }
    end
  end

  # PATCH /answers/:id
  def update
    respond_to do |format|
      if @answer.update(answer_params)
        format.turbo_stream
        format.html { redirect_to @answer.question, notice: "Answer was successfully updated" }
        format.json { render json: @answer, status: :ok }
      else
        format.turbo_stream { render :edit, status: :unprocessable_entity }
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @answer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /answers/:id
  def destroy
    @answer.destroy

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @answer.question, notice: "Answer was successfully deleted" }
      format.json { head :no_content }
    end
  end

  # PATCH /answers/:id/mark_as_best
  def mark_as_best
    Answer.transaction do
      # Remove best status from all other answers for this question
      @answer.question.answers.where(best: true).update_all(best: false)
      # Mark this answer as best
      @answer.update!(best: true)
    end

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @answer.question, notice: "Answer marked as best" }
      format.json { render json: @answer, status: :ok }
    end
  end

  private

  # Sets question from parameters
  def set_question
    @question = Question.find(params[:question_id])
  rescue ActiveRecord::RecordNotFound
    handle_record_not_found("Question")
  end

  # Sets answer from parameters
  def set_answer
    @answer = Answer.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    handle_record_not_found("Answer")
  end

  # Check if current user is the author of the answer
  def authorize_user!
    unless current_user == @answer.user
      redirect_to @answer.question, alert: "You can only edit your own answers"
    end
  end

  # Check if current user is the author of the question
  def authorize_question_author!
    unless current_user == @answer.question.user
      redirect_to @answer.question, alert: "Only the question author can mark answers as best"
    end
  end

  # Permitted parameters
  def answer_params
    params.require(:answer).permit(:body)
  end
end
