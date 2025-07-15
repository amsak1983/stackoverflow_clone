class QuestionsController < ApplicationController
  def new
    @question = Question.new
  end

  def create
    @question = Question.new(question_params)

    if @question.save
      redirect_to @question
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @question = Question.find(params[:id])
    @answer = @question.answers.new
  end

  private

  def question_params
    params.require(:question).permit(:title, :body)
  end
end
