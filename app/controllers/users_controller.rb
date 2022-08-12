# frozen_string_literal: true

class UsersController < ApplicationController
  # has_secure_password doesn't wrap password
  wrap_parameters :user, include: %i[username email password]

  def create
    @user = User.new(user_params)
    if @user.save
      session[:user_id] = @user.id
      ::UserMailer.sign_up(@user).deliver_later # deliver_later sends async, controller continues without waiting for email

      render status: :created
    else
      render json: { errors: @user.errors }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:username, :email, :password)
  end
end
