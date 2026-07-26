module Api
  class AuthController < ApplicationController
    def login
      user = User.find_by(email: params[:email])

      if user&.authenticate(params[:password])
        token = JwtService.encode(user_id: user.id)
        render json: {
          token: token,
          user: UserSerializer.new(user).as_json
        }, status: :ok
      else
        render json: { error: "Invalid email or password" }, status: :unauthorized
      end
    end

    def me
      authenticate_request
      return unless current_user

      render json: { user: UserSerializer.new(current_user).as_json }, status: :ok
    end
  end
end

