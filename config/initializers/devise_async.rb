if Rails.env.production?
  Devise::Models::Confirmable.class_eval do
    protected

    def send_devise_notification(notification, *args)
      devise_mailer.send(notification, self, *args).deliver_later
    end
  end
end
