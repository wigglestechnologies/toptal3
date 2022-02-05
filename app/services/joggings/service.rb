module Joggings
  class Service
    include ExceptionHandler
    include ErrorsFormater

    attr_reader :params, :errors

    def initialize(params = {}, current_user = nil)
      @current_user = current_user
      @params = params
      @errors = []
    end

    def create
      validate_user
      validate_duration if @params[:duration].present?
      @jogging = Jogging.create(@params.merge(user_id: @params[:user_id] || @current_user&.id).except(:id))
      finish_operation(true)
    end

    def update
      validate_user
      validate_duration if @params[:duration].present?
      @jogging = get_jogging
      @jogging.update(@params)
      finish_operation
    end

    def show
      json_view(get_jogging)
    end

    def index
      @joggings = Jogging.where(user_id: @current_user&.id)
                      .order('created_at DESC')
                      .page(@params[:page] || DEFAULT_PAGE)
                      .per(@params[:page_limit] || DEFAULT_PAGE_LIMIT)

      json_view(@joggings)
    end

    def destroy
      get_jogging
      @jogging.destroy!
      nil
    end

    def json_view(obj)
      obj.as_json(only: [:id, :lat, :lon, :distance, :date, :user_id],
                  include: {:user => {only: [:full_name]}, :weather => {only: [:temp_c, :temp_f, :weather_type]}},
                  methods: [:jogging_duration])
    end

    private

    def get_jogging
      @jogging = Jogging.find(@params[:id])
    end

    def validate_user
      invalid_user = @params[:user_id].present? && !User.where(id: @params[:user_id], active: true).any?

      raise ValidationError, [{message: I18n.t("errors.user_must_exist")}] if invalid_user
    end

    def validate_duration
      h_m_s_array = @params[:duration].split(':')
      sum = 0
      h_m_s_array.each do |elem|
        sum += elem.to_i
      end
      raise ValidationError, [{message: I18n.t("errors.duration_invalid")}] if h_m_s_array.empty? || h_m_s_array.size > 3 || sum <= 0

    rescue
      raise ValidationError, [{message: I18n.t("errors.duration_invalid")}]
    end

    def finish_operation(make_weather_integration = false)
      errors = fill_errors(@jogging)
      throw_exception(errors) if errors.any?
      Joggings::WeatherService.new(@jogging).call if make_weather_integration
      json_view(@jogging)
    end

    def throw_exception(errors)
      raise ValidationError, errors
    end
  end
end
