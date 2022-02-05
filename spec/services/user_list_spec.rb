require 'rails_helper'
require_relative '../helpers/methods'

describe 'List and reports Service' do

  before do
    generate_user_filters
  end

  it "1. should return user list" do
    create_three_users

    user_json = FilterService.new(User.where(active: true), nil, USER_FIELDS).call
    expect(user_json[0]['full_name']).to eq('test user 2') #its ordered by created at DESC
    expect(user_json[0]['email']).to eq('third@gmail.com')
    expect(user_json[0]['role']).to eq('regular')
    expect(user_json.size).to eq(3)
  end

  it "1.1 should return email-filtered user list " do
    create_three_users

    user_json = FilterService.new(User.where(active: true), @user_query_by_email, USER_FIELDS).call
    expect(user_json[0]['full_name']).to eq('test user')
    expect(user_json[0]['email']).to eq('first@gmail.com')
    expect(user_json[0]['role']).to eq('regular')
    expect(user_json.size).to eq(1)
  end

  it "1.2 should return email-filtered user list " do
    create_three_users

    user_json = FilterService.new(User.where(active: true), @user_query_by_email_ne, USER_FIELDS).call
    expect(user_json[0]['full_name']).to eq('test user 2')
    expect(user_json[0]['email']).to eq('third@gmail.com')
    expect(user_json[0]['role']).to eq('regular')
    expect(user_json.size).to eq(2)
  end

  it "1.3 should return role-filtered user list " do
    create_three_users('regular', 'regular', 'admin')

    user_json = FilterService.new(User.where(active: true), @user_query_by_role_eq, USER_FIELDS).call
    expect(user_json[0]['full_name']).to eq('test user 2')
    expect(user_json[0]['email']).to eq('third@gmail.com')
    expect(user_json[0]['role']).to eq('admin')
    expect(user_json.size).to eq(1)
  end

  it "1.4 should return role-filtered user list " do
    create_three_users('regular', 'regular', 'admin')

    user_json = FilterService.new(User.where(active: true), @user_query_by_role, USER_FIELDS).call
    expect(user_json[0]['full_name']).to eq('test user 1')
    expect(user_json[0]['email']).to eq('second@gmail.com')
    expect(user_json[0]['role']).to eq('regular')
    expect(user_json.size).to eq(2)
  end

  it "1.5 should return full_name-filtered user list " do
    create_three_users('regular', 'regular', 'admin')

    user_json = FilterService.new(User.where(active: true), @user_query_by_fullname, USER_FIELDS).call
    expect(user_json[0]['full_name']).to eq('test user')
    expect(user_json[0]['role']).to eq('regular')
    expect(user_json.size).to eq(1)
  end

  it "1.6 should return full_name-filtered user list " do
    create_three_users('regular', 'regular', 'admin')

    user_json = FilterService.new(User.where(active: true), @user_query_by_fullname_ne, USER_FIELDS).call
    expect(user_json[0]['full_name']).to eq('test user 2')
    expect(user_json[0]['role']).to eq('admin')
    expect(user_json.size).to eq(2)
  end

  it "1.7 should return all user list " do
    create_three_users('regular', 'regular', 'admin')
    user_json = FilterService.new(User.where(active: true), @user_nil_query, USER_FIELDS).call
    expect(user_json.size).to eq(3)
  end

  it "1.8 should return empty user list " do
    create_three_users('regular', 'regular', 'admin')

    user_json = FilterService.new(User.where(active: true), @user_multi_query, USER_FIELDS).call
    expect(user_json.size).to eq(0)
  end

  it "1.9 should return one user entry " do
    create_three_users('admin', 'admin', 'admin')

    user_json = FilterService.new(User.where(active: true), @user_multi_query, USER_FIELDS).call
    expect(user_json.size).to eq(1)
  end

  it "1.10 should return two user entry " do
    create_three_users('admin', 'manager', 'admin')

    user_json = FilterService.new(User.where(active: true), @user_multi_or_query, USER_FIELDS).call
    expect(user_json.size).to eq(2)
  end

  it "1.11 should raise an error: incorrect filter format" do
    create_three_users('regular', 'regular', 'admin')

    expect {
      FilterService.new(User.where(active: true), @user_invalid_chars_query, USER_FIELDS).call.size
    }.to raise_error(ActiveRecord::StatementInvalid)
  end
end