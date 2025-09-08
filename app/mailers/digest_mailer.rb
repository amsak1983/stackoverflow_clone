class DigestMailer < ApplicationMailer
  default from: "noreply@stackoverflow-clone.com"

  def daily_digest(user, questions)
    @user = user
    @questions = questions
    mail(to: @user.email, subject: "Daily questions digest")
  end
end
