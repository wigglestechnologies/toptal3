require 'rails_helper'
require_relative '../../helpers/methods'

describe 'Authentication Service' do

  before do
    initialize_user
    @auth_valid_params = { username: 'shota@mail.ru', password: 'Pass123!' }
    @auth_invalid_password = { username: 'test@gmail.com', password: nil}
    @auth_invalid_username = { username: nil, password: 'Password1$'}
    @wrong_credentials = { username: 'test@test.com', password: 'Password1$'}
  end

  it '1. should return jwt token and refresh token' do
    service = Auth::Service.new
    result = service.authenticate!(@auth_valid_params)

    expect(result[:token]).not_to be nil
    expect(result[:refresh_token]).not_to be nil
  end

  it '1.1 should add data into white list of tokens' do
    service = Auth::Service.new
    expect { service.authenticate!(@auth_valid_params) }.to change {AllowedToken.count}.by(1)
  end

  it '2. should throw exception with invalid password' do
    service = Auth::Service.new
    expect {
      service.authenticate!(@auth_invalid_password)
    }.to raise_error(AuthenticationError)
  end

  it '3. should throw exception with invalid username' do
    service = Auth::Service.new
    expect {
      service.authenticate!(@auth_invalid_username)
    }.to raise_error(AuthenticationError)
  end

  it '4. should throw exception with invalid credentials' do
    service = Auth::Service.new
    expect {
      service.authenticate!(@wrong_credentials)
    }.to raise_error(AuthenticationError)
  end

end