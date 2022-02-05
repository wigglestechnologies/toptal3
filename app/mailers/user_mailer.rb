class UserMailer < ApplicationMailer
  def registration_invite(token, email)
    @token = token
    @url  = "#{ENV['INVITE_LINK']}/registration/start/#{token}"
    text = "Invitation to take home project"
    mail(:to => email, :subject => text)
  end

  def registration_confirmed(user)
    @greeting = 'Hello ' + (user&.full_name || '')
    mail(:to => user.email, :subject => "WELCOME TO TAKE HOME PROJECT")
  end

  def reset_password_email(user)
    @greeting = "#{user&.full_name}, "
    @url  = "#{ENV['INVITE_LINK']}/auth/reset-password/#{user.reset_password_token}"
    text = "Password Change Requested"
    mail(:to => user.email, :subject => text)
  end

  def password_change(user)
    @greeting = 'Hello ' + (user&.full_name || '')
    text = "Password Changed Successfully"
    mail(:to => user.email, :subject => text)
  end
end
