require 'rails_helper'
require_relative '../../helpers/methods'

describe 'Report Service' do
  before do
    initialize_user
    create_joggings('12-10-2020')
  end

  it "1. should return jogging report list" do
    create_joggings('28-09-2020')
    jogging_report = Reports::Service.new(@user).call

    expect(jogging_report.length).to eq(2)
  end

  it "1.1 should return only one user's jogging report list " do
    create_joggings('05-10-2020')
    create_joggings('06-06-2020')
    user = create(:user, email: "jogging@mail.ru", password: "Pass123!")
    create(:jogging, user_id: user.id)
    jogging_report = Reports::Service.new(@user).call

    expect(jogging_report.length).to eq(3)
  end

  it "1.2 should return only one user's jogging report list " do
    create_joggings('05-10-2020')
    user = create(:user, email: "jogging@mail.ru", password: "Pass123!")
    create(:jogging, user_id: user.id)
    jogging_report = Reports::Service.new(nil).call

    expect(jogging_report.length).to eq(0)
  end

  it "1.3 should return only one user's jogging report list " do
    create_joggings('05-10-2020')
    jogging_report = Reports::Service.new(@user).call
    expect(jogging_report[0].total_distance).to eq(9000)
    expect(jogging_report[0].average_speed).to eq(9000/((60*60*3)/60))
  end


end