class AnswersController < ApplicationController
  include ResourceHandling
  
  before_action :set_question, only: [:create]
  before_action :authorize_question_author!, only: [:mark_as_best]
  
  # Override create to handle question association
  def create
    @answer = @question.answers.new(resource_params)
    @answer.user = current_user
    
    respond_to do |format|
      if @answer.save
        handle_success(format, @answer, "Answer was successfully created")
      else
        @answers = @question.answers.sorted_by_best
        handle_failure(format, @answer, :new)
      end
    end
  end
  
  # Override edit to handle Turbo Stream
  def edit
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @answer.question }
    end
  end
  
  # Override update to handle Turbo Stream
  def update
    respond_to do |format|
      if @answer.update(resource_params)
        handle_success(format, @answer, "Answer was successfully updated")
      else
        handle_failure(format, @answer, :edit)
      end
    end
  end
  
  # Override destroy to handle Turbo Stream
  def destroy
    @answer.destroy
    
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @answer.question, notice: "Answer was successfully deleted" }
      format.json { head :no_content }
    end
  end
  
  # PATCH /answers/:id/mark_as_best
  def mark_as_best
    Answer.transaction do
      # Remove best status from all other answers for this question
      @answer.question.answers.where(best: true).update_all(best: false)
      # Mark this answer as best
      @answer.update!(best: true)
    end
    
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @answer.question, notice: "Answer marked as best" }
      format.json { render json: @answer, status: :ok }
    end
  end
  
  private
  
  # ResourceHandling methods
  def resource_class
    Answer
  end
  
  def permitted_params
    [:body]
  end
  
  # Override resource name for Answer since it's nested under Question
  def resource_name
    'answer'
  end
  
  # Override to handle question association for new answers
  def new_resource
    @question.answers.new
  end
  
  # Sets question from parameters
  def set_question
    @question = Question.find(params[:question_id])
  rescue ActiveRecord::RecordNotFound
    handle_record_not_found("Question")
  end
  
  # Sets resource from parameters (overrides ResourceHandling#set_resource)
  def set_resource
    @answer = resource_class.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    handle_record_not_found("Answer")
  end
  
  # Override to handle question path
  def resource_path(resource = nil)
    resource ||= instance_variable_get("@#{resource_name}")
    resource.question
  end
  
  # Override to include question association in success redirect
  def handle_success(format, resource, notice)
    format.turbo_stream
    format.html { redirect_to resource_path(resource), notice: notice }
    format.json { render :show, status: :ok, location: resource_path(resource) }
  end
  
  # Override to handle Turbo Stream failure responses
  def handle_failure(format, resource, action)
    format.turbo_stream { render action, status: :unprocessable_entity }
    format.html { render action, status: :unprocessable_entity }
    format.json { render json: resource.errors, status: :unprocessable_entity }
  end
  
  # Check if current user is the author of the answer
  def authorize_user!
    unless current_user == @answer.user
      redirect_to @answer.question, alert: "You can only edit your own answers"
    end
  end
  
  # Check if current user is the author of the question
  def authorize_question_author!
    @answer ||= resource_class.find(params[:id])
    unless current_user == @answer.question.user
      redirect_to @answer.question, alert: "Only the question author can mark answers as best"
    end
  rescue ActiveRecord::RecordNotFound
    handle_record_not_found("Answer")
  end
end
