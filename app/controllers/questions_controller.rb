class QuestionsController < ApplicationController
  include ErrorHandling
  before_action :authenticate_user!, except: [ :index, :show ]
  before_action :set_question, only: [ :show, :destroy ]
  before_action :check_author, only: [ :destroy ]

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
    @question = current_user.questions.new(question_params)

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

  # DELETE /questions/:id
  def destroy
    @question.destroy
    redirect_to questions_path, notice: "Question was successfully deleted"
  end

  private

  # Sets question from parameters
  def set_question
    @question = Question.find_by(id: params[:id])
    handle_record_not_found("Question") unless @question
  end

  # Permitted parameters
  def question_params
    params.require(:question).permit(:title, :body)
  end

  # Check if current user is the author of the question
  def check_author
    unless current_user&.author_of?(@question)
      redirect_to questions_path, alert: "You do not have permission to delete this question"
    end
  end
end
