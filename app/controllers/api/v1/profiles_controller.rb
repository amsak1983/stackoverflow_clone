module Api
  module V1
    class ProfilesController < BaseController
      def index
        users = policy_scope(User).where.not(id: current_user.id)
        render json: users, each_serializer: UserSerializer
      end

      def me
        authorize current_user, :show?
        render json: current_user, serializer: UserSerializer
      end
    end
  end
end
