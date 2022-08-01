class UserMailer < ApplicationMailer

  def sign_up(user)
    @user = user
    mail(to: 'jeremaia.harrison@gmail.com', subject: 'Welcome to My Awesome Site') 
  end

  def forgot_email(user)
    @user = user
    @token = user.signed_id(expires_in: 15.minutes)
    mail(to: 'jeremaia.harrison@gmail.com', subject: 'Password reset')
  end
end
