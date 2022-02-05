module Reports
  class Service

    def initialize(current_user = nil)
      @current_user = current_user
      get_sql_for_report
    end

    def call
      @current_user ? Jogging.select(@report_select).where(@report_filter).group(@group_by).order(@order_by) : []
    end

    private

    def get_sql_for_report
      @report_select = "DATE_TRUNC('week', date)::DATE AS week,
                       SUM(distance) AS total_distance,
                       ROUND(CAST(SUM(distance) AS DECIMAL)/(CAST(SUM(seconds) AS DECIMAL)/#{SEC_IN_MIN_AMOUNT} ), 2) AS average_speed,
                       ROW_NUMBER() OVER (ORDER BY user_id) AS id"
      @report_filter = "user_id = #{@current_user&.id}"
      @group_by = "user_id, DATE_TRUNC('week', date)::DATE"
      @order_by = "week DESC"
    end
  end
end
