class PasswordController < ApplicationController

  def forgot
    result = Password::Service.new(forgot_pass_params).generate_password_token
    respond_json(result)
  end

  # After successfully Password Change It makes Auto Login
  # Response is JWT and Refresh tokens
  def reset
    password_reset_result = Password::Service.new(pass_params).call
    result = Auth::Service.new(client_headers).authenticate!(password_reset_result)
    respond_json(result)
  end

  private
  def pass_params
    params.permit(:token, :password, :password_confirmation)
  end

  def forgot_pass_params
    params.permit(:token, :password, :password_confirmation, :email)
  end
end
