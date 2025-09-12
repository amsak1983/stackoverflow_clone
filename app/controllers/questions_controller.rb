class QuestionsController < ApplicationController
  include ErrorHandling
  before_action :authenticate_user!, except: [ :index, :show ]
  before_action :set_question, only: [ :show, :edit, :update, :destroy ]
  after_action :verify_authorized, except: [ :index, :show ]

  # GET /questions
  def index
    @questions = Question.recent

    @query = params[:query].to_s.strip
    @model = params[:model].presence || "all"

    return if @query.blank?

    case @model
    when "questions"
      @search_results = wrap_results(Question.search_simple(@query).records)
    when "answers"
      @search_results = wrap_results(Answer.search_simple(@query).records)
    when "comments"
      @search_results = wrap_results(Comment.search_simple(@query).records)
    when "users"
      @search_results = wrap_results(User.search_simple(@query).records)
    else
      results = []
      results += wrap_results(Question.search_simple(@query).records)
      results += wrap_results(Answer.search_simple(@query).records)
      results += wrap_results(Comment.search_simple(@query).records)
      results += wrap_results(User.search_simple(@query).records)
      @search_results = results.sort_by { |r| r[:created_at] || Time.at(0) }.reverse
    end
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

  def wrap_results(records)
    Array(records).map do |record|
      case record
      when Question
        {
          model: "Question",
          title: record.title,
          text: record.body.to_s.truncate(180),
          path: question_path(record),
          created_at: record.created_at
        }
      when Answer
        {
          model: "Answer",
          title: "Answer to question: #{record.question.title.truncate(60)}",
          text: record.body.to_s.truncate(180),
          path: question_path(record.question, anchor: "answer_#{record.id}"),
          created_at: record.created_at
        }
      when Comment
        owner = record.commentable
        owner_title = case owner
        when Question then owner.title
        when Answer then "Answer to: #{owner.question.title}"
        else owner.class.name
        end
        {
          model: "Comment",
          title: "Comment to: #{owner_title.to_s.truncate(60)}",
          text: record.body.to_s.truncate(180),
          path: case owner
                when Question then question_path(owner, anchor: "comment_#{record.id}")
                when Answer then question_path(owner.question, anchor: "comment_#{record.id}")
                else "#"
                end,
          created_at: record.created_at
        }
      when User
        {
          model: "User",
          title: record.name,
          text: record.email,
          path: "#",
          created_at: record.created_at
        }
      else
        { model: record.class.name, title: record.try(:to_s), text: "", path: "#" }
      end
    end
  end

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
