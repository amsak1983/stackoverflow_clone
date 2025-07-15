# Контроллер для управления вопросами
class QuestionsController < ApplicationController
  before_action :set_question, only: [:show]

  # GET /questions
  def index
    @questions = Question.recent
  end

  # GET /questions/new
  def new
    @question = Question.new
  end

  # POST /questions
  def create
    @question = Question.new(question_params)

    if @question.save
      flash[:notice] = 'Вопрос успешно создан'
      redirect_to @question
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /questions/:id
  def show
    @answer = @question.answers.new
  end

  private

  # Устанавливает вопрос из параметров
  def set_question
    @question = Question.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = 'Вопрос не найден'
    redirect_to questions_path
  end

  # Разрешенные параметры
  def question_params
    params.require(:question).permit(:title, :body)
  end
end
