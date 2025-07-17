class AnswersController < ApplicationController
  include ErrorHandling
  before_action :set_question

  # POST /questions/:question_id/answers
  def create
    @answer = @question.answers.new(answer_params)

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

  private

  # Sets question from parameters
  def set_question
    @question = Question.find(params[:question_id])
  rescue ActiveRecord::RecordNotFound
    handle_record_not_found("Question")
  end

  # Permitted parameters
  def answer_params
    params.require(:answer).permit(:body)
  end
end
