require 'rails_helper'

RSpec.describe Jogging, type: :model do

  it "is valid with valid attributes" do
    user = create(:user, email: "test@mail.ru", password: "Pass123!")

    expect(Jogging.create(lon: 13, lat: 13, distance: 1000, date: '10-10-2020', duration: "01:30", user_id: user.id).id).not_to be nil
  end

  it "is not valid without an user_id" do
    jogging = Jogging.create(lon: 13, lat: 13, distance: 1000, date: '10-10-2020', duration: '01:30')
    expect(jogging).to_not be_valid
  end

  it "is not valid without a date" do
    user = create(:user, email: "test@mail.ru", password: "Pass123!")
    jogging = Jogging.create(lon: 13, lat: 13, distance: 1000, user_id: user.id, duration: '01:30')
    expect(jogging).to_not be_valid
  end

  it "is not valid date format" do
    user = create(:user, email: "test@mail.ru", password: "Pass123!")
    jogging = Jogging.create(lon: 13, lat: 13, distance: 1000, user_id: user.id, duration: '01:30', date: DateTime.now)
    expect(jogging).to_not be_valid
  end

  it "is not valid without a duration" do
    user = create(:user, email: "test@mail.ru", password: "Pass123!")
    jogging = Jogging.create(lon: 13, lat: 13, distance: 1000, user_id: user.id, date: '10-10-2020')
    expect(jogging).to_not be_valid
  end

  it "is not valid duration format" do
    user = create(:user, email: "test@mail.ru", password: "Pass123!")
    jogging = Jogging.create(lon: 13, lat: 13, distance: 1000, user_id: user.id, date: '10-10-2020', duration: 900)
    expect(jogging).to_not be_valid
  end

  it "is valid without a lon" do
    user = create(:user, email: "test@mail.ru", password: "Pass123!")
    jogging = Jogging.create(lat: 13, distance: 1000, user_id: user.id, date: '10-10-2020',duration: '01:30')
    expect(jogging.id).not_to be nil
  end

  it "is not valid a lon value" do
    user = create(:user, email: "test@mail.ru", password: "Pass123!")
    jogging = Jogging.create(lat: 13, distance: 1000, user_id: user.id,
                          duration: '01:30', date: '10-10-2020', lon: -1000)
    expect(jogging).to_not be_valid
  end

  it "is valid without a lat" do
    user = create(:user, email: "test@mail.ru", password: "Pass123!")
    jogging = Jogging.create(lon: 13, distance: 1000, user_id: user.id, duration: '01:30', date: '10-10-2020')
    expect(jogging.id).not_to be nil
  end

  it "is not valid a lat value" do
    user = create(:user, email: "test@mail.ru", password: "Pass123!")
    jogging = Jogging.create(lon: 13, lat: 500, distance: 1000, user_id: user.id, duration: '01:30', date: '10-10-2020',)
    expect(jogging).to_not be_valid
  end

end
