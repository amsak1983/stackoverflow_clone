class AnswersController < ApplicationController
  before_action :set_question

  # POST /questions/:question_id/answers
  def create
    @answer = @question.answers.new(answer_params)

    respond_to do |format|
      if @answer.save
        format.html { redirect_to @question, notice: 'Ответ успешно создан' }
        format.json { render json: @answer, status: :created, location: @question }
      else
        @answers = @question.answers.newest_first
        format.html { render 'questions/show', status: :unprocessable_entity }
        format.json { render json: @answer.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  # Устанавливает вопрос из параметров
  def set_question
    @question = Question.find(params[:question_id])
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.html do
        flash[:alert] = 'Вопрос не найден'
        redirect_to questions_path
      end
      format.json { render json: { error: 'Вопрос не найден' }, status: :not_found }
    end
  end

  # Разрешенные параметры
  def answer_params
    params.require(:answer).permit(:body)
  end
end
