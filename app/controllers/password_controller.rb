# frozen_string_literal: true

class PasswordController < ApplicationController
  def forgot
    return render json: { error: 'Email not present' } if params[:email].blank? # check if email is present

    user = User.find_by(email: params[:email]) # if present find user by email

    if user.present?

      ::UserMailer.forgot_email(user).deliver_later # deliver_later sends async, controller continues without waiting for email
      render json: { status: 'ok' }, status: :ok
    else
      render json: { error: ['Email address not found. Please check and try again.'] }, status: :not_found
    end
  end

  def reset
    token = params[:token].to_s
binding.pry
    return render json: { error: 'Email not present' } if params[:email].blank?

    user = User.find_signed(token)

    if user.present?
      if user.reset_password!(params[:password])
        render json: { status: 'ok' }, status: :ok
      else
        render json: { error: user.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { error: ['Link not valid or expired. Try generating a new link.'] }, status: :not_found
    end
  end
end
