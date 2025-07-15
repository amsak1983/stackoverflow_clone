# Controller for managing questions
class QuestionsController < ApplicationController
  before_action :set_question, only: [ :show ]

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

    respond_to do |format|
      if @question.save
        format.html { redirect_to @question, notice: "Question was successfully created" }
        format.json { render :show, status: :created, location: @question }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @question.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /questions/:id
  def show
    @answer = Answer.new
    @answers = @question.answers.newest_first
  end

  private

  # Sets question from parameters
  def set_question
    @question = Question.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.html do
        flash[:alert] = "Question not found"
        redirect_to questions_path
      end
      format.json { render json: { error: "Question not found" }, status: :not_found }
    end
  end

  # Permitted parameters
  def question_params
    params.require(:question).permit(:title, :body)
  end
end
