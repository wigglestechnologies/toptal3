class AuthController < ApplicationController

  def login
    result = Auth::Service.new(client_headers).authenticate!(auth_params)
    respond_json(result)
  end

  def logout
    result = RefreshToken::Service.new(client_headers).destroy_token!
    respond_json(result)
  end

  def refresh_token
    result = RefreshToken::Service.new(client_headers).refresh_token!
    respond_json(result)
  end

  private
  def auth_params
    params.permit(:username, :password)
  end
end
