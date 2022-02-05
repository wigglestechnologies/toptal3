require 'rails_helper'
require_relative '../../helpers/methods'

describe 'User Service' do

  before do
    initialize_user
    @valid_regular_params = {email: 'new_regular@email.com', password: "Pass123!",  password_confirmation: "Pass123!"}
    @update_valid_param = {id: @user.id, email: 'update@email.com', full_name: "new name", role: 'admin'}
  end

  it '1. should create new regular/manager/admin user' do
    expect {Admin::UserService.new(@valid_regular_params).create}.to change {User.count}.by(1)
  end

  it '1.1 should create regular user' do
    user_json = Admin::UserService.new(@valid_regular_params).create
    expect(user_json['role']).to eq('regular')
  end

  it '1.2. should create manager user' do
    user_json = Admin::UserService.new(@valid_regular_params.merge(role: 'manager')).create
    expect(user_json['role']).to eq('manager')
  end

  it '1.3. should create admin user' do
    user_json = Admin::UserService.new(@valid_regular_params.merge(role: 'admin')).create
    expect(user_json['role']).to eq('admin')
  end

  it '1.4. should return Validation error with invalid email' do
    service = Admin::UserService.new(@valid_regular_params.merge(email: 'invalid email'))
    expect {service.create}.to raise_error(ValidationError)
  end

  it '1.5. should return Validation error with invalid password' do
    service = Admin::UserService.new(@valid_regular_params.merge(password: 'invalid password'))
    expect {service.create}.to raise_error(ValidationError)
  end

  it '1.6. should return Validation error with no match passwords' do
    service = Admin::UserService.new(@valid_regular_params.merge(password_confirmation: 'invalid password'))
    expect {service.create}.to raise_error(ValidationError)
  end

  it "2. should return user data" do
    user_json = Admin::UserService.new({id: @user.id}).show
    expect(user_json['full_name']).to eq('test user')
    expect(user_json['email']).to eq('shota@mail.ru')
    expect(user_json['role']).to eq('regular')
  end

  it "2.1 should return user not found error" do
    service = Admin::UserService.new({id: nil})
    expect {service.show}.to raise_error(ActiveRecord::RecordNotFound)
  end

  it "3. should update users full name" do
    user_json = Admin::UserService.new(@update_valid_param).update
    expect(user_json['full_name']).to eq('new name')
    expect(user_json['email']).to eq('update@email.com')
    expect(user_json['role']).to eq('admin')
  end

  it "3.1. should return Validation error with invalid update password" do
    service = Admin::UserService.new(@update_valid_param.merge(password: 'invalid password'))
    expect {service.update}.to raise_error(ValidationError)
  end

  it "3.2. should return Validation error with invalid update email" do
    service = Admin::UserService.new(@update_valid_param.merge(email: 'invalid email'))
    expect {service.update}.to raise_error(ValidationError)
  end

  it "3.3. should return Validation error with invalid update role" do
    service = Admin::UserService.new(@update_valid_param.merge(role: 'invalid role'))
    expect {service.update}.to raise_error(ValidationError)
  end

  it "4. should destroy user" do
    user_to_destroy = create(:user, email: "destroyable@gmail.com", password: "Pass123!", full_name: 'test user')
    Admin::UserService.new({id: user_to_destroy.id}).destroy
    expect(User.find(user_to_destroy.id).active).to be false
  end

  it "4.1 should return RecordNotFound error while destroying" do
    service = Admin::UserService.new({id: nil})
    expect {service.destroy}.to raise_error(ActiveRecord::RecordNotFound)
  end

  it "4.2 should not destroy the only admin user in the system" do
    admin_user = create(:user, email: "admin1@gmail.com", password: "Pass123!", role: 'admin')
    service = Admin::UserService.new({id: admin_user.id})
    expect {service.destroy}.to raise_error(Pundit::NotAuthorizedError)
  end

  it "4.3 should  destroy if two admin im the system" do
    f_admin_user = create(:user, email: "admin2@gmail.com", password: "Pass123!", role: 'admin')
    create(:user, email: "admin3@gmail.com", password: "Pass123!", role: 'admin')
    Admin::UserService.new({id: f_admin_user.id}).destroy
    expect(User.find(f_admin_user.id).active).to be false
  end
end