class VotesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_votable

  def create
    value = params.require(:value).to_i

    result = case value
    when 1
               @votable.vote_up(current_user)
    when -1
               @votable.vote_down(current_user)
    else
               return render_error("Invalid vote value", :unprocessable_entity)
    end

    if result
      render_vote_response
    else
      render_error("Unable to vote", :unprocessable_entity)
    end
  end

  def destroy
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
