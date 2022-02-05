require 'rails_helper'
require_relative '../../helpers/methods'

describe 'Registration service' do
  it '1. should return new tokens' do
    expect { Registration::Service.new({email: 'new_email@user.com'}).call }.to change  { RegistrationDetail.count }.by(1)
  end

  it '2. should invalidate existed token' do
    Registration::Service.new({email: 'new_email@user.com'}).call
    token = RegistrationDetail.last.token
    params = {email: 'new_email@user.com', token: token, password: 'Password12!', password_confirmation: 'Password12!'}
    expect { Registration::ConfirmationService.new(params).call }.to change  { RegistrationDetail.count }.by(-1)
  end

  it '2.1 should register new user' do
    Registration::Service.new({email: 'new_email@user.com'}).call
    token = RegistrationDetail.last.token
    params = {email: 'new_email@user.com', token: token, password: 'Password12!', password_confirmation: 'Password12!'}
    expect { Registration::ConfirmationService.new(params).call }.to change  { User.count }.by(1)
  end

  it '2.2 should not register new user, password' do
    Registration::Service.new({email: 'new_email@user.com'}).call
    token = RegistrationDetail.last.token
    params = {email: 'new_email@user.com', token: token, password: 'Password12!', password_confirmation: 'Passwor2!'}
    service = Registration::ConfirmationService.new(params)
    expect {service.call}.to raise_error(ValidationError)
  end
end