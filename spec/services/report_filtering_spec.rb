require 'rails_helper'
require_relative '../helpers/methods'

describe 'reports list and filtering Service' do

  before do
    initialize_user
    generate_report_filters
    create_joggings('12-10-2020')
    @jogging_report = Reports::Service.new(@user).call
    @ordering = 'date DESC'
  end

  it "1. should return jogging report list" do
    report_list = FilterService.new(@jogging_report, nil, REPORT_FIELDS, nil, true).call
    expect(report_list.length).to eq(1)
  end

  it "1.1 should return date-filtered jogging report list all gt/eq/lt filters " do
    filter_by_date_gt = FilterService.new(@jogging_report, @report_query_by_week_gt, REPORT_FIELDS, nil, true).call
    expect(filter_by_date_gt.length).to eq(0)
    filter_by_date_eq = FilterService.new(@jogging_report, @report_query_by_week_eq, REPORT_FIELDS, nil, true).call
    expect(filter_by_date_eq.length).to eq(1)
    filter_by_date_lt = FilterService.new(@jogging_report, @report_query_by_week_lt, REPORT_FIELDS, nil, true).call
    expect(filter_by_date_lt.length).to eq(0)
    filter_by_date_ne = FilterService.new(@jogging_report, @report_query_by_week_ne, REPORT_FIELDS, nil, true).call
    expect(filter_by_date_ne.length).to eq(0)
  end

  it "1.2 should return distance-filtered jogging report list " do
    filtered_eq = FilterService.new(@jogging_report, @report_query_by_distance_eq, REPORT_FIELDS, nil, true).call
    expect(filtered_eq.length).to eq(0)
    filtered_ne = FilterService.new(@jogging_report, @report_query_by_distance_ne, REPORT_FIELDS, nil, true).call
    expect(filtered_ne.length).to eq(1)
    filtered_gt = FilterService.new(@jogging_report, @report_query_by_distance_gt, REPORT_FIELDS, nil, true).call
    expect(filtered_gt.length).to eq(1)
    filtered_lt = FilterService.new(@jogging_report, @report_query_by_distance_lt, REPORT_FIELDS, nil, true).call
    expect(filtered_lt.length).to eq(0)

  end

  it "1.4 should return speed -filtered jogging report list " do

    filtered_multi = FilterService.new(@jogging_report, @report_query_by_speed_eq, REPORT_FIELDS, nil, true).call
    expect(filtered_multi.length).to eq(0)
    filtered_with_date = FilterService.new(@jogging_report, @report_query_by_speed_gt, REPORT_FIELDS, nil, true).call
    expect(filtered_with_date.length).to eq(0)
    filtered_with_lt = FilterService.new(@jogging_report, @report_multi_query_and, REPORT_FIELDS, nil, true).call
    expect(filtered_with_lt.length).to eq(1)
  end

  it "1.5 should return all jogging report list " do
    report_list = FilterService.new(@jogging_report,  { filters: nil }, REPORT_FIELDS, nil, true).call
    expect(report_list.length).to eq(1)
  end

  it "1.6 should return empty jogging report list " do
    report_list = FilterService.new(@jogging_report, @report_multi_query, REPORT_FIELDS, nil, true).call
    expect(report_list.length).to eq(0)
  end

  it "1.7 should raise an error: incorrect filter format" do
    expect {
      FilterService.new(@jogging_report, @report_invalid_chars_query, REPORT_FIELDS, nil, true).call.length
    }.to raise_error(ActiveRecord::StatementInvalid)
  end

  it "2. should return only first page" do
    create(:jogging, user_id: @user.id, date: '28-09-2020')

    report_list = FilterService.new(@jogging_report, {page: 1, page_limit: 1}, REPORT_FIELDS, nil, true).call
    expect(report_list.length).to eq(1)
    report_list = FilterService.new(@jogging_report, {page: 2, page_limit: 1}, REPORT_FIELDS, nil, true).call
    expect(report_list.length).to eq(1)
    report_list = FilterService.new(@jogging_report, {page: 2, page_limit: 10}, REPORT_FIELDS, nil, true).call
    expect(report_list.length).to eq(0)
    report_list = FilterService.new(@jogging_report, {page: 1, page_limit: 10}, REPORT_FIELDS, nil, true).call
    expect(report_list.length).to eq(2)
    report_list = FilterService.new(@jogging_report, {page: nil, page_limit: nil}, REPORT_FIELDS, nil, true).call
    expect(report_list.length).to eq(2)
  end
end