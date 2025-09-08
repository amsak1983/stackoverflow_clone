class DailyDigestJob < ApplicationJob
  queue_as :default

  def perform
    questions = Question.where("created_at >= ?", 24.hours.ago).order(created_at: :desc)
    return if questions.empty?

    User.where.not(confirmed_at: nil).find_each(batch_size: 500) do |user|
      DigestMailer.daily_digest(user, questions).deliver_now
    end
  end
end
