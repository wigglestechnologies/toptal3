require 'rails_helper'
require_relative '../helpers/methods'

describe 'Jogging List and filters Service' do

  before do
    initialize_user
    generate_jogging_filters
    @joggings = Jogging.joins(:user).where('users.active = ?', true)
    @ordering = 'date DESC'
  end

  it "1. should return jogging list" do
    create_joggings

    jogging_json = FilterService.new(@joggings, nil, JOGGING_FIELDS, @ordering).call
    expect(jogging_json[0]['user_id']).to eq(@user.id)
    expect(jogging_json.size).to eq(3)
  end

  it "1.1 should return date-filtered jogging list all gt/eq/lt filters " do
    create_joggings

    filter_by_date_gt = FilterService.new(@joggings, @jogging_query_by_date_gt, JOGGING_FIELDS, @ordering).call
    expect(filter_by_date_gt.size).to eq(3)
    filter_by_date_eq = FilterService.new(@joggings, @jogging_query_by_date_eq, JOGGING_FIELDS, @ordering).call
    expect(filter_by_date_eq.size).to eq(0)
    filter_by_date_lt = FilterService.new(@joggings, @jogging_query_by_date_lt, JOGGING_FIELDS, @ordering).call
    expect(filter_by_date_lt.size).to eq(0)
    filter_by_date_en = FilterService.new(@joggings, @jogging_query_by_date_ne, JOGGING_FIELDS, @ordering).call
    expect(filter_by_date_en.size).to eq(3)
  end

  it "1.2 should return distance-filtered jogging list " do
    create_joggings

    filtered_eq = FilterService.new(@joggings, @jogging_query_by_distance_eq, JOGGING_FIELDS, @ordering).call
    expect(filtered_eq.size).to eq(0)
    filtered_ne = FilterService.new(@joggings, @jogging_query_by_distance_ne, JOGGING_FIELDS, @ordering).call
    expect(filtered_ne.size).to eq(3)
    filtered_gt = FilterService.new(@joggings, @jogging_query_by_distance_gt, JOGGING_FIELDS, @ordering).call
    expect(filtered_gt.size).to eq(3)
    filtered_lt = FilterService.new(@joggings, @jogging_query_by_distance_lt, JOGGING_FIELDS, @ordering).call
    expect(filtered_lt.size).to eq(0)

  end

  it "1.3 should return duration-filtered jogging list " do
    create_joggings

    filtered_eq = FilterService.new(@joggings, @jogging_query_by_duration_eq, JOGGING_FIELDS, @ordering).call
    expect(filtered_eq.size).to eq(3)
    filtered_ne = FilterService.new(@joggings, @jogging_query_by_duration_ne, JOGGING_FIELDS, @ordering).call
    expect(filtered_ne.size).to eq(0)
    filtered_gt = FilterService.new(@joggings, @jogging_query_by_duration_gt, JOGGING_FIELDS, @ordering).call
    expect(filtered_gt.size).to eq(0)
    filtered_lt = FilterService.new(@joggings, @jogging_query_by_duration_lt, JOGGING_FIELDS, @ordering).call
    expect(filtered_lt.size).to eq(3)
  end

  it "1.4 should return lan and lot -filtered jogging list " do
    create_joggings
    create(:jogging, user_id: @user.id, date: '09-10-2020', lon: 52, lat: 2 )

    filtered_multi = FilterService.new(@joggings, @jogging_lon_lat_multi_and, JOGGING_FIELDS, @ordering).call
    expect(filtered_multi.size).to eq(0)
    filtered_with_date = FilterService.new(@joggings, @jogging_lon_lat_multi_or, JOGGING_FIELDS, @ordering).call
    expect(filtered_with_date.size).to eq(4)
    filtered_with_lt = FilterService.new(@joggings, @jogging_lon_lat_multi_lt, JOGGING_FIELDS, @ordering).call
    expect(filtered_with_lt.size).to eq(1)
  end

  it "1.5 should return all jogging list " do
    create_joggings
    jogging_json = FilterService.new(@joggings,  { filters: nil }, JOGGING_FIELDS, @ordering).call
    expect(jogging_json.size).to eq(3)
  end

  it "1.6 should return empty jogging list " do
    create_joggings

    jogging_json = FilterService.new(@joggings, @jogging_multi_query, JOGGING_FIELDS, @ordering).call
    expect(jogging_json.size).to eq(0)
  end

  it "1.7 should raise an error: incorrect filter format" do
    create_joggings

    expect {
      FilterService.new(@joggings, @jogging_invalid_chars_query, JOGGING_FIELDS, @ordering).call.size
    }.to raise_error(ActiveRecord::StatementInvalid)
  end
end