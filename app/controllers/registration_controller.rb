class RegistrationController < ApplicationController

  def sign_up_authentication
    result = Registration::Service.new(sign_up_authentication_params).call
    respond_json(result)
  end

  def confirm_sign_up
    result = Registration::ConfirmationService.new(confirmation_params).call
    respond_json(result, :created)
  end

  private

  def sign_up_authentication_params
    params.permit(:email, :role)
  end

  def confirmation_params
    params.permit(:token, :full_name, :password, :password_confirmation)
  end
end