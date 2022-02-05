REGISTRATION_TOKENS_LIFE_TIME = 24 #hours
RESET_PASSWORD_TOKENS_LIFE_TIME = 24 #hours
REFRESH_TOKEN_EXPIRED_MIN = 24*60*3
JWT_TOKEN_EXPIRED_MIN = 15 #minutes

DEFAULT_PAGE = 1
DEFAULT_PAGE_LIMIT = 15
PAGE_LIMIT_MAX = 100

PASS_PREFIX = 'v@P1'

WEATHER_API_KEY = "a0d9dc53c5b74f6d817113644200710"
WEATHER_HISTORICAL_API = "http://api.weatherapi.com/v1/history.json"

# JOGGIND VALIDATIONS CONSTNTS
MAX_LAT = 89.999
MIN_LAT = -89.999
MAX_LON = 189.999
MIN_LON = -189.999
MIN_YEAR = 100
DURATION_FORMAT = 'hh:nn:ss'
DATE_FORMAT = 'DD-MM-YYYY'
ZERO = 0

DURATION_MAX = 24
DURATION_MIN = 0

# User Validations constants
STRING_MAX_LIMIT = 250
STRING_MIN_LIMIT = 8
REGEX_EMAIL = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

SEC_IN_MIN_AMOUNT = 60.00

# For Filtering
FILTER_REGEX = /([ ()])(?=(?:[^']*'[^']*')*[^']*$)/
PARENTHESIS = ['and', 'or', '(', ')', ' ']
OPERATION_HASH = {
    'eq' => '=',
    'ne' => '!=',
    'gt' => '>',
    'gtoe' => '>=',
    'lt' => '<',
    'ltoq' => '<=',
}
ROLES_INTO_NUMBER = {
    'regular' => 0,
    'manager' => 1,
    'admin' => 2,
}

JOGGING_FIELDS = ['date', 'duration', 'distance', 'lon', 'lat', 'user_id', 'id']
USER_FIELDS = ['email', 'full_name', 'role', 'id', 'lat', 'user_id']
REPORT_FIELDS = ["ROUND(CAST(SUM(distance) AS DECIMAL)/(SUM(seconds)/#{SEC_IN_MIN_AMOUNT}), 2)", 'SUM(distance)', "DATE_TRUNC('week', date)::DATE"]

REPORT_FILTER_HASH = {
    'total_distance' => "SUM(distance)",
    'average_speed' => "ROUND(CAST(SUM(distance) AS DECIMAL)/(SUM(seconds)/#{SEC_IN_MIN_AMOUNT}), 2)",
    'week' =>"DATE_TRUNC('week', date)::DATE"
}