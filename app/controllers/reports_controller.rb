class ReportsController < ApplicationController
  before_action :validate_authentication

  def index
    @report = Reports::Service.new(@current_user).call
    data = FilterService.new(@report, filter_params, REPORT_FIELDS, nil, true).call
    respond_json({ data:  data, total_count: data.total_count })
  end

  private
  def filter_params
    params.permit(:page, :page_limit, :filters)
  end
end
