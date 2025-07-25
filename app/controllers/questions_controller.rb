class QuestionsController < ApplicationController
  include ResourceHandling

  # Override show to include answers
  def show
    @answer = Answer.new
    @answers = @question.answers.newest_first
  end

  private

  # ResourceHandling methods
  def resource_class
    Question
  end

  def permitted_params
    [ :title, :body ]
  end

  def scope_method
    :recent
  end

  # Sets resource from parameters
  def set_resource
    @question = resource_class.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    handle_record_not_found("Question")
  end

  # Authorizes the user for resource modification
  def authorize_user!
    unless current_user == @question.user
      redirect_to @question, alert: "You are not authorized to perform this action."
    end
  end

  # Override default success handler to include answers in show action
  def handle_success(format, resource, notice)
    super
    @answers = resource.answers.newest_first if action_name == "show"
  end
end
