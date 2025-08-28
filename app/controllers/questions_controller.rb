class QuestionsController < ApplicationController
  include ErrorHandling
  before_action :authenticate_user!, except: [ :index, :show ]
  before_action :set_question, only: [ :show, :edit, :update, :destroy ]
  after_action :verify_authorized, except: [ :index, :show ]

  # GET /questions
  def index
    @questions = Question.recent
  end

  # GET /questions/new
  def new
    @question = Question.new
    authorize @question
  end

  # POST /questions
  def create
    @question = current_user.questions.new(question_params)
    authorize @question

    # Associate reward with current user if present
    if @question.reward.present?
      @question.reward.user = current_user
    end

    respond_to do |format|
      if @question.save
        QuestionBroadcaster.append(@question)
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
    authorize @question
  end

  # PATCH/PUT /questions/:id
  def update
    authorize @question
    respond_to do |format|
      if @question.update(question_params)
        QuestionBroadcaster.update(@question)
        format.html { redirect_to @question, notice: "Question was successfully updated" }
        format.turbo_stream { render :update, status: :ok }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.turbo_stream { render turbo_stream: turbo_stream.replace(@question, partial: "questions/form", locals: { question: @question }), status: :unprocessable_content }
      end
    end
  end

  # DELETE /questions/:id
  def destroy
    authorize @question
    @question.destroy
    QuestionBroadcaster.remove(@question)
    redirect_to questions_path, notice: "Question was successfully deleted"
  end



  private

  def set_question
    @question = Question.find_by(id: params[:id])
    handle_record_not_found("Question") unless @question
  end

  def question_params
    params.require(:question).permit(:title, :body, files: [],
      links_attributes: [ :id, :name, :url, :_destroy ],
      reward_attributes: [ :id, :title, :image, :_destroy ])
  end
end
