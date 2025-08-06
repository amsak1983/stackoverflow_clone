# Helper methods for votes functionality in views
module VotesHelper
  # Renders voting controls for a votable resource
  # @param votable [ActiveRecord::Base] the votable resource (Question or Answer)
  # @return [String] HTML for voting controls
  def render_voting_controls(votable)
    return "" unless current_user && !current_user.author_of?(votable)

    user_vote = votable.vote_value_by(current_user)
    upvote_class = user_vote == 1 ? "text-green-600" : "text-gray-600 hover:text-green-600"
    downvote_class = user_vote == -1 ? "text-red-600" : "text-gray-600 hover:text-red-600"

    content_tag(:div, class: "flex items-center space-x-2") do
      concat(render_vote_button(votable, 1, "⬆", upvote_class))
      concat(content_tag(:span, votable.rating, class: "font-bold text-gray-700", id: "#{dom_id(votable)}-rating"))
      concat(render_vote_button(votable, -1, "⬇", downvote_class))
      if user_vote
        concat(render_cancel_vote_button(votable))
      end
    end
  end

  # Renders a vote button (upvote or downvote)
  # @param votable [ActiveRecord::Base] the votable resource
  # @param value [Integer] the vote value (1 or -1)
  # @param icon [String] the button icon/text
  # @param css_class [String] CSS classes for the button
  # @return [String] HTML for the vote button
  def render_vote_button(votable, value, icon, css_class)
    button_to icon,
              polymorphic_path([ votable, :votes ], votable: votable.class.name.underscore),
              method: :post,
              params: { value: value },
              class: "#{css_class} font-bold text-xl focus:outline-none",
              form: { class: "inline-block", data: { turbo: true, action: "click->votes#vote" } }
  end

  # Renders a cancel vote button
  # @param votable [ActiveRecord::Base] the votable resource
  # @return [String] HTML for the cancel vote button
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
