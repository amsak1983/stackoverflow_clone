module ControllerHelpers
  def login(user)
    @request.env['devise.mapping'] = Devise.mappings[:user]
    sign_in(user, scope: :user)
  end

  def sign_in_user(user)
    @request.env['devise.mapping'] = Devise.mappings[:user]
    sign_in(user, scope: :user)
  end
  
  def setup_controller_for_warden
    @request.env['action_dispatch.request.parameters'] = { action: controller.action_name, controller: controller.controller_path }
    @request.env['action_controller.instance'] = controller
  end
end

RSpec.configure do |config|
  config.include ControllerHelpers, type: :controller
end
