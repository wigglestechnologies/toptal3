require 'rails_helper'

RSpec.describe Weather, type: :model do

  it "is valid with valid attributes" do
    user = create(:user, email: "test@mail.ru", password: "Pass123!")
    jogging = Jogging.create(lon: 13, lat: 13, distance: 1000, date: '10-10-2020', duration: '01:30', user_id: user.id)
    expect(Weather.create(jogging_id: jogging.id)).to be_valid
  end

  it "is not valid without a jogging" do
    weather = Weather.create
    expect(weather).to_not be_valid
  end
end
