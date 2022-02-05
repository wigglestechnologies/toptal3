class Jogging < ApplicationRecord
  belongs_to :user
  has_one :weather, dependent: :destroy

  validates :distance, presence: true, numericality: {only_integer: true, greater_than: ZERO}
  validates :date, presence: true
  validates :duration, presence: true
  validates :lat, numericality: {greater_than_or_equal_to: MIN_LAT, less_than_or_equal_to: MAX_LAT}, allow_nil: true
  validates :lon, numericality: {greater_than_or_equal_to: MIN_LON, less_than_or_equal_to: MAX_LON}, allow_nil: true

  validates_time :duration, format: DURATION_FORMAT
  validates_date :date, on_or_before: lambda {Date.today}, after: lambda {MIN_YEAR.years.ago},
                 on_or_before_message: I18n.t("errors.on_or_before_message"), format: DATE_FORMAT

  before_save :set_weather, Proc.new {|model| model.date_changed? || model.lon_changed? || model.lat_changed?}
  before_save :set_seconds

  def jogging_duration
    self.duration.strftime("%H:%M:%S")
  end

  private

  def set_seconds
    self.seconds = Time.parse(self.duration.strftime("%H:%M:%S")).seconds_since_midnight.to_i if self.duration.present?
  end

  def set_weather
    Joggings::WeatherService.new(self).call
  end
end
