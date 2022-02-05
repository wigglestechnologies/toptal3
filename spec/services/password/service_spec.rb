require 'rails_helper'
require_relative '../../helpers/methods'

describe 'Password service' do
  before do
    initialize_user
  end

  it '1. should return reset_password_token' do
    Password::Service.new({email: 'shota@mail.ru'}).generate_password_token
    expect(User.where(email: @user.email).first.reset_password_token).not_to be nil
  end

  it '2. should change password' do
    Password::Service.new({email: 'shota@mail.ru'}).generate_password_token
    token = User.where(email: @user.email).first.reset_password_token
    Password::Service.new({email: 'shota@mail.ru', token: token, password: 'PAssword12!', password_confirmation: 'PAssword12!'}).call

    expect(User.where(email: @user.email).first.reset_password_token).to be nil
  end

  it '2.1 should throw validation error, invalid token' do
    service = Password::Service.new({email: 'shota@mail.ru', token: "invalid token", password: 'PAssword12!', password_confirmation: 'PAssword12!'})
    expect {service.call}.to raise_error(ValidationError)
  end

  it '2.2 should throw validation error, invalid password' do
    service = Password::Service.new({email: 'shota@mail.ru', token: "invalid token",
                                     password: 'PAssword12!', password_confirmation: 'Password2!'})
    expect {service.call}.to raise_error(ValidationError)
  end
end