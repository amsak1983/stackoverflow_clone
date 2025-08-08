module VotesHelper
  def render_voting_controls(votable)
    return "" unless current_user && !current_user.author_of?(votable)

    user_vote = votable.vote_value_by(current_user)
    upvote_class = user_vote&.positive? ? "text-green-600" : "text-gray-600 hover:text-green-600"
    downvote_class = user_vote&.negative? ? "text-red-600" : "text-gray-600 hover:text-red-600"

    content_tag(:div, class: "flex items-center space-x-2") do
      concat(render_vote_button(votable, 1, "⬆", upvote_class))
      concat(content_tag(:span, votable.rating, class: "font-bold text-gray-700", id: "#{dom_id(votable)}-rating"))
      concat(render_vote_button(votable, -1, "⬇", downvote_class))
      if user_vote
        concat(render_cancel_vote_button(votable))
      end
    end
  end

  def render_vote_button(votable, value, icon, css_class)
    action = value.positive? ? :up : :down

    if votable.is_a?(Question)
      path = send("#{action}_question_votes_path", votable, votable: "question")
    else
      path = send("#{action}_answer_votes_path", votable, votable: "answer")
    end

    button_to icon,
              path,
              method: :post,
              class: "#{css_class} font-bold text-xl focus:outline-none",
              form: { class: "inline-block", data: { turbo: true, action: "click->votes#vote" } }
  end

  def render_cancel_vote_button(votable)
    vote = votable.votes.find_by(user: current_user)
    return "" unless vote

    if votable.is_a?(Answer)
      path = vote_path(vote, votable: "answer", answer_id: votable.id)
    else
      path = question_vote_path(votable, vote)
    end

    button_to "✕",
              path,
              method: :delete,
              class: "text-gray-400 hover:text-gray-600 text-sm ml-2",
              form: { class: "inline-block", data: { turbo: true, action: "click->votes#cancelVote" } }
  end
end
