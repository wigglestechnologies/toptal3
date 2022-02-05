require 'rails_helper'

RSpec.describe User, type: :model do
  it "is valid with valid attributes" do
    expect(User.create(email: 'test@gmail.com', password: 'Password1$')).to be_valid
  end

  it "is not valid without an email" do
    user = User.create(email: nil, password: 'Password1$')
    expect(user).to_not be_valid
  end

  it "is not valid without a password" do
    user = User.create(password: nil, email: 'test@gmail.com')
    expect(user).to_not be_valid
  end

  it "is not valid email format" do
    user = User.create(email: 'invalid email', password: 'Password1$')
    expect(user).to_not be_valid
  end

  it "is not valid password format" do
    user = User.create(password: 'invalid_password', email: 'test@gmail.com')
    expect(user).to_not be_valid
  end

  it "returns users regular role" do
    user = User.create(password: 'invalid_password', email: 'test@gmail.com')
    expect(user.role).to eq('regular')
  end

  it "returns users admin role" do
    user = User.create(password: 'invalid_password', email: 'test@gmail.com', role: 'manager')
    expect(user.role).to eq('manager')
  end
end
