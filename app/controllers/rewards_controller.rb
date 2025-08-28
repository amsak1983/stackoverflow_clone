class RewardsController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized

  def index
    authorize Reward
    @received_rewards = current_user.received_rewards.includes(:question, image_attachment: :blob)
    @created_rewards = current_user.created_rewards.includes(:question, :recipient, image_attachment: :blob)
  end
end
