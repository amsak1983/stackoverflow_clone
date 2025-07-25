class QuestionsController < ApplicationController
  include ErrorHandling
  before_action :authenticate_user!, except: [:index, :show]
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
    @question.user = current_user

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
    handle_record_not_found("Question")
  end

  # Permitted parameters
  def question_params
    params.require(:question).permit(:title, :body)
  end
end
