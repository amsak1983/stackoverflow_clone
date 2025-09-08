class SubscriptionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_question, only: [:create]
  before_action :set_subscription, only: [:destroy]

  def create
    subscription = @question.subscriptions.find_or_initialize_by(user: current_user)

    if subscription.persisted? || subscription.save
      redirect_to @question, notice: "You are subscribed to question updates"
    else
      redirect_to @question, alert: "Failed to subscribe to updates"
    end
  end

  def destroy
    question = @subscription.question

    if @subscription.user_id == current_user.id
      @subscription.destroy
      redirect_to question, notice: "You have unsubscribed from question updates"
    else
      redirect_to question, alert: "You can only unsubscribe from your own subscriptions"
    end
  end

  private

  def set_question
    @question = Question.find(params[:question_id])
  end

  def set_subscription
    @subscription = Subscription.find(params[:id])
  end
end

