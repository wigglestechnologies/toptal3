require 'rails_helper'

RSpec.describe AllowedToken, type: :model do

  it "is valid with valid attributes" do
    user = create(:user, email: "test@mail.ru", password: "Pass123!")
    expect(AllowedToken.create(user_id: user.id, encrypted_token: 'random_token_string', expired_at: DateTime.now)).to be_valid
  end

  it "is not valid without an user_id" do
    allowed_token = AllowedToken.create(encrypted_token: 'random_token_string', expired_at: DateTime.now)
    expect(allowed_token).to_not be_valid
  end

  it "is not valid without an encrypted_token" do
    user = create(:user, email: "test@mail.ru", password: "Pass123!")
    allowed_token = AllowedToken.create(user_id: user.id, expired_at: DateTime.now)
    expect(allowed_token).to_not be_valid
  end

  it "is not valid without an expired_at" do
    user = create(:user, email: "test@mail.ru", password: "Pass123!")
    allowed_token = AllowedToken.create(encrypted_token: 'random_token_string', user_id: user.id)
    expect(allowed_token).to_not be_valid
  end

end
