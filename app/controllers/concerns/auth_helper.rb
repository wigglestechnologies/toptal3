module AuthHelper

  def validate_authentication
    result = Jwt::Validator.new(bearer_token).call
    @current_user = current_account
    render :json => {}, status: 401 if result.nil? || !result.valid? || @current_user.nil?
  end

  def current_account
    return nil unless request.headers['Authorization']
    user_id = get_user_id
    @current_user ||= User.where(active: true, id: user_id).first
  end

  private

  def get_user_id
    splitted_token = token.split('.').second
    if splitted_token
      payload = Base64.decode64(splitted_token)
      JSON.parse(payload)['user_id']
    end
  end

  def token
    pattern = /^Bearer /
    token = request.headers['Authorization']
    token.gsub(pattern, "") if token&.match(pattern)
  end

  def bearer_token
    pattern = /^Bearer /
    header = request.headers["Authorization"]
    header.gsub(pattern, '') if header&.match(pattern)
  end

  def client_headers
    {
        ip: request.env['HTTP_CLIENT_IP'] || request.remote_ip,
        user_agent: request.env['HTTP_USER_AGENT'],
        bearer_token: bearer_token
    }
  end
end

