module Api
  class UsersController < ApplicationController
    before_action :authenticate_request
    before_action :require_admin!, except: [:index]

    def index
      users = User.all.order(created_at: :desc)
      render json: { data: users.map { |user| UserSerializer.new(user).as_json } }, status: :ok
    end

    def create
      user = User.new(user_params)

      if user.save
        render json: { data: UserSerializer.new(user).as_json }, status: :created
      else
        render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def destroy
      user = User.find(params[:id])
      user.destroy
      head :no_content
    end

    private

    def user_params
      params.permit(:name, :email, :password, :password_confirmation, :role)
    end
  end
end

