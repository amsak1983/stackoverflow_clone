class VotesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_votable
  before_action :check_author, only: [ :create ]

  # Creates a new vote or updates existing one
  def create
    value = params.require(:value).to_i

    # Validate vote value
    unless valid_vote_value?(value)
      return render_error("Invalid vote value", :unprocessable_entity)
    end

    # Try to vote
    result = @votable.vote_by(current_user, value)

    if result
      render_vote_response
    else
      # User already voted with the same value
      render_error("You already voted with this value", :unprocessable_entity)
    end
  end

  # Cancels user's vote for the votable resource
  def destroy
    @votable.cancel_vote_by(current_user)
    render_vote_response(nil)
  end

  private

  # Sets the votable object based on params
  def set_votable
    votable_type = params[:votable].classify
    votable_id = params["#{params[:votable]}_id"]

    # Check if votable type is allowed
    unless allowed_votable_types.include?(votable_type)
      return render_error("Invalid votable type", :bad_request)
    end

    @votable = votable_type.constantize.find(votable_id)
  end

  # Prevents authors from voting on their own content
  def check_author
    render_error("Author cannot vote for their own content", :forbidden) if current_user.author_of?(@votable)
  end

  # Returns standard JSON response for vote actions
  def render_vote_response(user_vote = @votable.vote_value_by(current_user))
    render json: { rating: @votable.rating, user_vote: user_vote }
  end

  # Returns error JSON response
  def render_error(message, status)
    render json: { error: message }, status: status
  end

  # Allowed vote values
  def valid_vote_value?(value)
    [ -1, 1 ].include?(value)
  end

  # Allowed votable types
  def allowed_votable_types
    [ "Question", "Answer" ]
  end
end
