class QuestionsController < ApplicationController
  include ErrorHandling
  before_action :authenticate_user!, except: [ :index, :show ]
  before_action :set_question, only: [ :show, :edit, :update, :destroy ]
  before_action :check_author, only: [ :edit, :update, :destroy ]

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
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @question.errors, status: :unprocessable_content }
      end
    end
  end

  # GET /questions/:id
  def show
    @answer = Answer.new
    @answers = @question.answers.best_first
  end

  # GET /questions/:id/edit
  def edit
  end

  # PATCH/PUT /questions/:id
  def update
    respond_to do |format|
      if @question.update(question_params)
        format.html { redirect_to @question, notice: "Question was successfully updated" }
        format.turbo_stream { render :update, status: :ok }
      else
        format.html { render "questions/show", status: :unprocessable_content }
        format.turbo_stream { render turbo_stream: turbo_stream.replace(@question, partial: "questions/form", locals: { question: @question }), status: :unprocessable_content }
      end
    end
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
    params.require(:question).permit(:title, :body, files: [])
  end

  # Check if current user is the author of the question
  def check_author
    return if current_user&.author_of?(@question)

    respond_to do |format|
      format.html { redirect_to questions_path, alert: "You do not have permission to modify this question" }
      format.json { head :forbidden }
      format.turbo_stream { head :forbidden }
    end
    head :forbidden and return
  end
end
