def auth_schema
  {
      username: {type: :string},
      password: {type: :string},
  }
end

def auth_response_schema
  {
      token: {type: :string},
      refresh_token: {type: :string}
  }
end

def login_params
  {
      username: 'a@a.com',
      password: 'Password123!',

  }
end

def login_response_schema
  {
      data: {
          type: :object,
          properties: auth_response_schema,
          required: ['token', 'refresh_token']
      }
  }
end

def user_creation_schema
  {
      type: :object,
      properties:
          {
              role: {type: :string},
              full_name: {type: :string},
              email: {type: :string},
              password: {type: :string},
              password_confirmation: {type: :string}
          }
  }
end

def user_update_schema
  {
      type: :object,
      properties:
          {
              role: {type: :string},
              full_name: {type: :string},
              email: {type: :string},
              password: {type: :string},
              password_confirmation: {type: :string}
          },
      required: ['id']
  }
end

def user_response
  {
      id: {type: :integer},
      role: {type: :string},
      full_name: {type: :string},
      email: {type: :string}
  }
end

def jogging_params_schema
  {
      type: :object,
      properties: {
          date: {type: :string},
          duration: {type: :string},
          lon: {type: :number},
          lat: {type: :number},
          user_id: {type: :integer},
          distance: {type: :integer},
      }
  }
end

def jogging_response_schema
  {  type: :object,
     properties: {
         id: {type: :integer},
         date: {type: :string},
         duration: {type: :string},
         lon: {type: :number},
         lat: {type: :number},
         user_id: {type: :integer},
         distance: {type: :integer},
         weather: {
             type: :object,
             properties: {
                 temp_c: {type: :string},
                 temp_f: {type: :string},
                 weather_type: {type: :string},
             }
         },
         user: {
             type: :object,
             properties: {
                 user_id: {type: :string},
             }
         }
     }
  }
end

def user_creation_params(role: 'regular', email: 'foo@foo.com')
  {
      email: email,
      password: 'Pass123!',
      password_confirmation: 'Pass123!',
      full_name: 'test',
      role: role
  }
end

def user_update_params(role: nil)
  { full_name: 'name_update', role: role }.compact
end

def user_update_invalid_params
  { email: 'invalid_email' }
end

def user_creation_invalid_params
  {
      email: 'invalid_email',
      password: 'Pass123!',
      password_confirmation: 'Pass123!',
      full_name: 'test'
  }
end

def initialize_user(role = 'regular')
  params = {username: "shota@mail.ru", password: "Pass123!"}
  @user = create(:user, email: "shota@mail.ru", password: "Pass123!", full_name: 'test user', role: role)
  result = Auth::Service.new.authenticate!(params)
  @refresh_token = result[:refresh_token]
  @jwt_token = result[:token]
end

def regular_user(user_name = 'regular')
  params = {username: "#{user_name}@mail.ru", password: "Pass123!"}
  regular_user = create(:user, email: "#{user_name}@mail.ru", password: "Pass123!", full_name: "#{user_name} user", role: 'regular')
  result = Auth::Service.new.authenticate!(params)
  format_user_object(regular_user, result)
end

def manager_user(user_name = 'manager')
  params = {username: "#{user_name}@mail.ru", password: "Pass123!"}
  manager_user = create(:user, email: "#{user_name}@mail.ru", password: "Pass123!", full_name: "#{user_name} user", role: 'manager')
  result = Auth::Service.new.authenticate!(params)
  format_user_object(manager_user, result)
end

def admin_user(user_name = 'admin')
  params = {username: "#{user_name}@mail.ru", password: "Pass123!"}
  admin_user = create(:user, email: "#{user_name}@mail.ru", password: "Pass123!", full_name: "#{user_name} user", role: 'admin')
  result = Auth::Service.new.authenticate!(params)
  format_user_object(admin_user, result)
end

def format_user_object(user, authenticated)
  {
      id: user.id,
      email: user.email,
      refresh_token: authenticated[:refresh_token],
      jwt_token: authenticated[:token],
      role: user.role
  }
end

def error_response_parser(response)
  data = JSON.parse(response.body)
  if data['errors'].is_a?(String)
    JSON.parse(data['errors'].gsub('=>', ':'))
  else
    data['errors']
  end
end

def regular_user_update_schema
  {
      type: :object,
      properties:
          {
              full_name: {type: :string},
              email: {type: :string},
              password: {type: :string},
              password_confirmation: {type: :string}
          }
  }
end

def create_three_users(f_role = 'regular', s_role = 'regular', t_role = 'regular')
  create(:user, email: "first@gmail.com", password: "Pass123!", full_name: 'test user', role: f_role)
  create(:user, email: "second@gmail.com", password: "Pass123!", full_name: 'test user 1', role: s_role)
  create(:user, email: "third@gmail.com", password: "Pass123!", full_name: 'test user 2', role: t_role)
end

def generate_user_filters
  name = "test user"

  @user_invalid_query = {filters: 'no_field eq first@gmail.com'}
  @user_invalid_chars_query = {filters: '(email eq first@gmail.com'}
  @user_nil_query = {filters: nil}
  @user_multi_query = {filters: '(email eq first@gmail.com AND role eq admin)'}
  @user_multi_or_query = {filters: "((full_name eq '#{name}' OR full_name eq '#{name + ' 1'}') AND (role eq admin OR role eq manager))"}
  @user_query_by_email = {filters: 'email eq first@gmail.com'}
  @user_query_by_email_ne = {filters: 'email ne first@gmail.com'}
  @user_query_by_role = {filters: 'role ne admin'}
  @user_query_by_role_eq = {filters: 'role eq admin'}
  @user_query_by_fullname_ne = {filters: "full_name ne '#{name}'"}
  @user_query_by_fullname = {filters: "full_name eq '#{name}'"}
end

def forget_password_token(email)
  Password::Service.new({ email: email }).generate_password_token
  User.where(email: email, active: true).first.reset_password_token
end

def new_password(token)
  {
      token: token,
      password: 'Pass123!1',
      password_confirmation: 'Pass123!1',
  }
end

def generate_jogging_filters
  duration = "01:00"
  sec_duration = "02:30"
  date = "10-10-2020"
  @jogging_invalid_query = {filters: 'no_field eq first@gmail.com'}
  @jogging_query_by_date_gt = {filters: "date gt '#{date}'"}
  @jogging_query_by_date_lt = {filters: "date lt '#{date}'"}
  @jogging_query_by_date_eq = {filters: "date eq '#{date}'"}
  @jogging_query_by_date_ne = {filters: "date ne '#{date}'"}
  @jogging_query_by_distance_lt = {filters: 'distance lt 1000'}
  @jogging_query_by_distance_ne = {filters: 'distance ne 1000'}
  @jogging_query_by_distance_eq = {filters: 'distance eq 1000'}
  @jogging_query_by_distance_gt = {filters: 'distance gt 500'}
  @jogging_query_by_duration_gt = {filters: "duration gt '#{duration}'"}
  @jogging_query_by_duration_lt = {filters: "duration lt '#{sec_duration}'"}
  @jogging_query_by_duration_eq = {filters: "duration eq '#{duration}'"}
  @jogging_query_by_duration_ne = {filters: "duration ne '#{duration}'"}

  @jogging_lon_lat_multi_or = {filters: 'lon gt -13 OR lat eq 13'}
  @jogging_lon_lat_multi_and = {filters: "(lon eq 13 OR lat eq 13) AND date eq '#{date}'"}
  @jogging_lon_lat_multi_lt = {filters: "(lon gt 13 OR lat lt 13) AND date lt '#{date}'"}

  @jogging_multi_query =  {filters: "(lon eq 13 OR lat eq 13) AND ( date lt '#{date}'  AND distance ne 1000)"}
  @jogging_invalid_chars_query =  {filters: "(lon eq 13 OR lat eq 13) AND ( date lt '#{date}'  AND distance ne 1000"}
end


def create_joggings(date = nil)
  date = date || DateTime.now.to_date.strftime("%d/%m/%Y")
  create(:jogging, user_id: @user.id, date: date)
  create(:jogging, user_id: @user.id, date: date)
  create(:jogging, user_id: @user.id, date: date)
end

def new_jogging_params(user_id)
  date = date || DateTime.now.to_date.strftime("%d/%m/%Y")
  jogging = create(:jogging, user_id: @user.id, date: date)
  {
      date: jogging.date,
      duration: jogging.duration,
      lon: jogging.lon,
      lat: jogging.lat,
      user_id: user_id,
      distance: jogging.distance
  }
end

def generate_report_filters
  week = '12-10-2020'
  @report_invalid_query = {filters: 'no_field eq first@gmail.com'}
  @report_query_by_week_gt = {filters: "week gt '#{week}'"}
  @report_query_by_week_lt = {filters: "week lt '#{week}'"}
  @report_query_by_week_eq = {filters: "week eq '#{week}'"}
  @report_query_by_week_ne = {filters: "week ne '#{week}'"}

  @report_query_by_distance_lt = {filters: 'total_distance lt 2000'}
  @report_query_by_distance_ne = {filters: 'total_distance ne 3000'}
  @report_query_by_distance_eq = {filters: 'total_distance eq 3000'}
  @report_query_by_distance_gt = {filters: 'total_distance gt 500'}

  @report_query_by_speed_lt = {filters: 'average_speed lt 1000'}
  @report_query_by_speed_ne = {filters: 'average_speed ne 1000'}
  @report_query_by_speed_eq = {filters: 'average_speed eq 1000'}
  @report_query_by_speed_gt = {filters: 'average_speed gt 500'}

  @report_multi_query = {filters: "(total_distance gt 1000 OR total_distance lt 3500) AND week lt '#{week}'"}
  @report_multi_query_or = {filters: 'total_distance gt 1000 OR total_distance lt 3500'}
  @report_multi_query_and = {filters: "(total_distance gt 1000 OR average_speed eq 100) AND week eq '#{week}'"}
  @report_invalid_chars_query =  {filters: "(total_distance gt 1000 OR total_distance eq 3000 AND week eq #{week}"}
end

def sign_up_token(email)
  Registration::Service.new({ email: email }).call
  RegistrationDetail.where(email: email).first.token
end