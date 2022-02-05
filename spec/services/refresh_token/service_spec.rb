require 'rails_helper'
require_relative '../../helpers/methods'

describe 'Refresh token service' do
  before do
    initialize_user
    @client_headers = { bearer_token: @refresh_token }
    @invalid_client_headers = { bearer_token: 'Bearer invalid_token' }
  end

  it '1. should return new tokens' do
    service = RefreshToken::Service.new(@client_headers)
    result = service.refresh_token!

    expect(result[:token]).not_to be nil
    expect(result[:refresh_token]).not_to be nil
  end

  it '2. should throw exception with invalid headers' do
    service = RefreshToken::Service.new(@invalid_client_headers)
    expect { service.refresh_token! }.to raise_error(AuthenticationError)
  end

  it '3. should destroy token' do
    service = RefreshToken::Service.new(@client_headers)
    expect { service.destroy_token! }.to change {AllowedToken.count}.by(-1)
  end

end