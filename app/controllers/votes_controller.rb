class VotesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_votable
  after_action :verify_authorized

  def up
    authorize @votable, policy_class: VotePolicy
    result = @votable.vote_up(current_user)

    if result
      render_vote_response
    else
      render_error("Unable to vote up", :unprocessable_content)
    end
  end

  def down
    authorize @votable, policy_class: VotePolicy
    result = @votable.vote_down(current_user)

    if result
      render_vote_response
    else
      render_error("Unable to vote down", :unprocessable_content)
    end
  end

  def destroy
    vote = @votable.votes.find_by(user: current_user)

    if vote
      authorize vote
    else
      skip_authorization
    end

    @votable.cancel_vote_by(current_user)
    render_vote_response(nil)
  end

  private

  def set_votable
    votable_param = params[:votable]&.to_s
    votable_id = params["#{votable_param}_id"]

    case votable_param
    when "question"
      @votable = Question.find(votable_id)
    when "answer"
      @votable = Answer.find(votable_id)
    else
      render_error("Invalid votable type", :bad_request)
    end
  end

  def render_vote_response(user_vote = @votable.vote_value_by(current_user))
    render json: { rating: @votable.rating, user_vote: user_vote }
  end

  def render_error(message, status)
    render json: { error: message }, status: status
  end

  def allowed_votable_types
    [ "Question", "Answer" ]
  end
end
