class AnswersController < ApplicationController
  include ErrorHandling
  before_action :authenticate_user!
  before_action :set_question, only: [ :create ]
  before_action :set_answer, only: [ :update, :destroy, :set_best ]
  before_action :check_author, only: [ :update, :destroy ]
  before_action :check_question_author, only: [ :set_best ]

  # POST /questions/:question_id/answers
  def create
    @answer = @question.answers.new(answer_params)
    @answer.user = current_user

    if @answer.save
      ActionCable.server.broadcast("questions/#{@question.id}/answers", {
        html: render_to_string(partial: "answers/answer", locals: { answer: @answer })
      })
      respond_to do |format|
        format.html { redirect_to @question, notice: "Answer was successfully created" }
        format.json { render json: @answer, status: :created, location: @question }
        format.turbo_stream { render :create, status: :ok }
      end
    else
      @answers = @question.answers.best_first
      respond_to do |format|
        format.html { render "questions/show", status: :unprocessable_content }
        format.json { render json: @answer.errors, status: :unprocessable_content }
        format.turbo_stream { render turbo_stream: turbo_stream.replace("new-answer", partial: "answers/form", locals: { answer: @answer }), status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /answers/:id
  def update
    respond_to do |format|
      if @answer.update(answer_params)
        format.html { redirect_to @answer.question, notice: "Answer was successfully updated" }
        format.turbo_stream
      else
        format.html { render "questions/show", status: :unprocessable_content }
        format.turbo_stream { render turbo_stream: turbo_stream.replace(@answer, partial: "answers/form", locals: { answer: @answer }) }
      end
    end
  end

  # DELETE /answers/:id
  def destroy
    @answer.destroy
    respond_to do |format|
      format.html { redirect_to @answer.question, notice: "Answer was successfully deleted" }
      format.turbo_stream
    end
  end

  # PATCH /answers/:id/set_best
  def set_best
    @answer.make_best!

    respond_to do |format|
      format.html { redirect_to @answer.question, notice: "Best answer selected" }
      format.turbo_stream
    end
  end



  private

  def set_question
    @question = Question.find(params[:question_id])
  end

  def set_answer
    @answer = Answer.find(params[:id])
  end

  def answer_params
    params.require(:answer).permit(:body, files: [],
      links_attributes: [ :id, :name, :url, :_destroy ])
  end

  def check_author
    return if current_user&.author_of?(@answer)

    respond_to do |format|
      format.html { redirect_to question_path(@answer.question), alert: "You do not have permission to modify this answer" }
      format.json { head :forbidden }
      format.turbo_stream { head :forbidden }
    end
    head :forbidden and return
  end

  def check_question_author
    return if current_user&.author_of?(@answer.question)

    respond_to do |format|
      format.html { redirect_to question_path(@answer.question), alert: "Only the question author can select the best answer" }
      format.json { head :forbidden }
      format.turbo_stream { head :forbidden }
    end
    head :forbidden and return
  end
end
