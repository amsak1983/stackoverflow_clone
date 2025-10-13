class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAILER_FROM_EMAIL", "noreply@stackoverflow-clone.com")
  layout "mailer"
end
