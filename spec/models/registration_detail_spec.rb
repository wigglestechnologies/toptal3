require 'rails_helper'

RSpec.describe RegistrationDetail, type: :model do
  it "is valid with valid attributes" do
    expect(RegistrationDetail.create(email: 'test@gmail.com', token: 'randomtokenstring', valid_until: DateTime.now)).to be_valid
  end

  it "is not valid without an email" do
    reg_detail = RegistrationDetail.create(email: nil, token: 'randomtokenstring', valid_until: DateTime.now)
    expect(reg_detail).to_not be_valid
  end

  it "is not valid email FORMAT" do
    reg_detail = RegistrationDetail.create(email: "nil", token: 'randomtokenstring', valid_until: DateTime.now)
    expect(reg_detail).to_not be_valid
  end

  it "is not valid without a token" do
    reg_detail = RegistrationDetail.create(email: 'test@gmail.com', token: nil, valid_until: DateTime.now)
    expect(reg_detail).to_not be_valid
  end
end
