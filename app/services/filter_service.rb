class FilterService
  attr_reader :fields, :query_params, :filter_values, :filter_keys

  def initialize(object_to_filter, query_params, fields, ordering = 'created_at DESC', report_filtering = false)
    @fields = fields
    @query_params = query_params[:filters] if query_params.present?
    @object_to_filter = object_to_filter

    @page = query_params.present? && query_params[:page].to_i ? query_params[:page].to_i : DEFAULT_PAGE
    invalid_pagination = query_params.nil? || query_params[:page_limit].nil? || query_params[:page_limit].to_i > PAGE_LIMIT_MAX
    @page_limit = invalid_pagination ? DEFAULT_PAGE_LIMIT : query_params[:page_limit].to_i

    @ordering = ordering

    @filter_keys = ''
    @filter_values = {}

    @report_filtering = report_filtering
  end

  def call
    generate_query(query_params.split(FILTER_REGEX).reject {|c| c.empty?}) if !query_params.nil? && query_params
    result = get_final_query
    result = result.order(@ordering) if @ordering.present?
    result.page(@page).per(@page_limit)
  end

  private

  # Generates query keys and values
  # -- keys -> 'date < :filter1'
  # -- values -> 'filter1: 12-10-2020'
  def generate_query(query_params_array)
    field_number = 0
    param_number = 0
    field_hash = {}
    query_params_array.each do |query_string|
      parsed_string = query_start_validation(query_string.downcase)
      if fields.include?(parsed_string)
        field_number += 1
        field_hash["filter#{field_number}".to_sym] = parsed_string
        filter_keys << parsed_string
      elsif !string_belongs_operations?(query_string) && !parsed_string.empty?
        param_number += 1
        filter_values["filter#{field_number}".to_sym] = get_value(query_string, field_hash, param_number)
        filter_keys << ":filter#{param_number}"
      end
    end
    raise ActiveRecord::StatementInvalid if field_number != param_number
  end

  # Checks if current part of filter is
  # an operation and not value or key
  def string_belongs_operations?(query_string)
    if OPERATION_HASH[query_string].present?
      filter_keys << OPERATION_HASH[query_string]
      true
    elsif PARENTHESIS.include?(query_string.downcase)
      filter_keys << query_string
      true
    else
      false
    end
  end

  # Gets value from the string
  # If needed
  def get_value(query_string, key_hash, number)
    query_string = query_start_validation(query_string)
    query_string = ROLES_INTO_NUMBER[query_string] if key_hash["filter#{number}".to_sym] == 'role'
    query_string = query_string.to_date if key_hash["filter#{number}".to_sym] == 'date' || key_hash["filter#{number}".to_sym] == "DATE_TRUNC('week', date)::DATE"

    query_string

  rescue
    raise ActiveRecord::StatementInvalid
  end

  def query_start_validation(query_string)
    query_string = REPORT_FILTER_HASH[query_string] || query_string
    if query_string[0] == "'" && query_string[-1] == "'" || query_string[0] == '"' && query_string[-1] == '"'
      query_string = query_string[1..-2]
    elsif query_string[0] == "'" && !query_string[-1] == "'" || query_string[0] == '"' && !query_string[-1] == '"'
      query_string = query_string[1..-1]
    elsif !query_string[0] == "'" && query_string[-1] == "'" || !query_string[0] == '"' && query_string[-1] == '"'
      query_string = query_string[0..-2]
    end
    query_string
  rescue
    raise ActiveRecord::StatementInvalid
  end

  def get_final_query
    if filter_keys.empty?
      @object_to_filter
    elsif @report_filtering
      @object_to_filter.having(filter_keys, filter_values)
    else
      @object_to_filter.where(filter_keys, filter_values)
    end
  rescue
    raise ActiveRecord::StatementInvalid
  end
end