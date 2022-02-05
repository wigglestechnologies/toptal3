require 'rails_helper'
require_relative '../../helpers/methods'

describe 'Joggings Service' do

  before do
    initialize_user
    @valid_params = { date: DateTime.now.to_date.strftime("%d/%m/%Y"), user_id: @user.id,
                      lon: 13, lat: 13, distance: 1000, duration: "01:00"}
    @valid_update_params = { date: (DateTime.now - 1.day).to_date.strftime("%d/%m/%Y"), user_id: @user.id,
                             lon: 52, lat: 2.26, distance: 6000, duration: "02:00"}
  end

  it '1. should create jogging with weather' do
    expect {Joggings::Service.new(@valid_params).create}.to change { Jogging.count }.by(1)
    expect {Joggings::Service.new(@valid_params).create}.to change { Weather.count }.by(1)
  end

  it '1.1. should not create jogging with invalid longitude' do
    service = Joggings::Service.new(@valid_params.merge(:lon => 900))
    expect {
      service.create
    }.to raise_error(ValidationError)
  end

  it '1.2. should not create jogging with invalid latitude' do
    service = Joggings::Service.new(@valid_params.merge(:lat => -911))
    expect {
      service.create
    }.to raise_error(ValidationError)
  end
  it '1.3. should not create jogging with invalid duration' do
    service = Joggings::Service.new(@valid_params.merge(:duration => 900))
    expect {
      service.create
    }.to raise_error(ValidationError)
  end

  it '1.4. should not create jogging with invalid date' do
    service = Joggings::Service.new(@valid_params.except(:date))
    expect {
      service.create
    }.to raise_error(ValidationError)
  end

  it '1.5. should not create jogging with invalid user' do
    service = Joggings::Service.new(@valid_params.except(:user_id))
    expect {
      service.create
    }.to raise_error(ValidationError)
  end

  it '1.6. should not create jogging with invalid distance' do
    service = Joggings::Service.new(@valid_params.except(:distance))
    expect {
      service.create
    }.to raise_error(ValidationError)
  end

  it "2. should return jogging data" do
    jogging = create(:jogging, user_id: @user.id)
    jogging_json = Joggings::Service.new({id: jogging.id}).show
    expect(jogging_json['user_id']).to eq(@user.id)
  end

  it "2.1 should return jogging not found error" do
    service =Joggings::Service.new({id: nil})
    expect {service.show}.to raise_error(ActiveRecord::RecordNotFound)
  end


  it "3. should update jogging distance amount and date, weather should be updated too" do

    jogging = create(:jogging, user_id: @user.id)

    jogging_json = Joggings::Service.new(@valid_update_params.merge(id: jogging.id)).update
    expect(jogging_json['distance']).to eq(6000)
    expect(jogging_json['jogging_duration']).to eq("02:00:00")
    expect(jogging_json['date']).to eq((DateTime.now - 1.day).to_date)
    expect(jogging_json['lon']).to eq(52)
    expect(jogging_json['lat']).to eq(2.26)
  end

  it "3.1. should return Validation error with invalid update password" do
    jogging = create(:jogging, user_id: @user.id)
    service = Joggings::Service.new(@valid_update_params.merge(date: 'invalid date', id: jogging.id))
    expect {service.update}.to raise_error(ValidationError)
  end

  it "3.2. should return RecordNotFound error" do
    service = Joggings::Service.new(@valid_update_params)
    expect {service.update}.to raise_error(ActiveRecord::RecordNotFound)
  end

  it "4. should destroy jogging" do
    jogging = create(:jogging, user_id: @user.id)
    expect {Joggings::Service.new({id: jogging.id}).destroy}.to change { Jogging.count }.by(-1)
  end

  it "4.1 should return record not found" do
    jogging = create(:jogging, user_id: @user.id)
    Joggings::Service.new({id: jogging.id}).destroy
    expect { Joggings::Service.new({id: jogging.id}).destroy }.to raise_error(ActiveRecord::RecordNotFound)
  end

  it '5 should update weather data' do
    jogging_id = Joggings::Service.new(@valid_params).create['id']
    weather = Jogging.find(jogging_id).weather
    Joggings::Service.new(@valid_update_params.merge(id: jogging_id)).update
    expect(Jogging.find(jogging_id).weather&.updated_at).not_to eq(weather&.updated_at)
  end

  it '5.1 should not update weather data' do
    jogging_id = Joggings::Service.new(@valid_params).create['id']
    weather = Jogging.find(jogging_id).weather
    Joggings::Service.new(@valid_update_params.merge(id: jogging_id).except(:lon, :lat,:date)).update
    expect(Jogging.find(jogging_id).weather&.weather_type).to eq(weather&.weather_type)
  end
end