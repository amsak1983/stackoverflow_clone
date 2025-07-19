class AnswersController < ApplicationController
  include ErrorHandling
  before_action :authenticate_user!
  before_action :set_question, only: [ :create ]
  before_action :set_answer, only: [ :destroy ]
  before_action :check_author, only: [ :destroy ]

  # POST /questions/:question_id/answers
  def create
    @answer = @question.answers.new(answer_params)
    @answer.user = current_user

    respond_to do |format|
      if @answer.save
        format.html { redirect_to @question, notice: "Answer was successfully created" }
        format.json { render json: @answer, status: :created, location: @question }
      else
        @answers = @question.answers.newest_first
        format.html { render "questions/show", status: :unprocessable_entity }
        format.json { render json: @answer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /answers/:id
  def destroy
    question = @answer.question
    @answer.destroy
    redirect_to question_path(question), notice: "Answer was successfully deleted"
  end

  private

  # Sets question from parameters
  def set_question
    @question = Question.find_by(id: params[:question_id])
    handle_record_not_found("Question") unless @question
  end

  # Sets answer from parameters
  def set_answer
    @answer = Answer.find_by(id: params[:id])
    handle_record_not_found("Answer") unless @answer
  end

  # Permitted parameters
  def answer_params
    params.require(:answer).permit(:body)
  end

  # Check if current user is the author of the answer
  def check_author
    unless current_user && current_user == @answer.user
      redirect_to question_path(@answer.question), alert: "You do not have permission to delete this answer"
    end
  end
end
