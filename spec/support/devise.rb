RSpec.configure do |config|
  # Конфигурация для Devise в тестах контроллеров
  config.before(:each, type: :controller) do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end
end
