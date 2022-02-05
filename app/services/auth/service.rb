module Auth
  class Service
    include ExceptionHandler

    attr_reader :client_headers, :bearer_token, :errors

    def initialize(client_headers = {})
      @client_headers = client_headers
      @bearer_token = client_headers[:bearer_token]
      @errors = []
    end

    def authenticate!(auth_params)
      user = find_user_with_credentials(auth_params)

      refresh_token = RefreshToken::GeneratorService.new.call
      refresh_token_service = TokenStorage::AutoLoginTokenService.new(user.id, client_headers)
      refresh_token_service.store_refresh_token(refresh_token)
      jwt_token = Jwt::Service.new(generate_payload(refresh_token_service), Jwt::Provider::Hmac.new).call
      { token: jwt_token, refresh_token: refresh_token }
    end

    private
    def find_user_with_credentials(auth_params)
      validate_params(auth_params)
      user = User.where(active: true).authenticate(auth_params[:username].downcase, auth_params[:password])
      raise AuthenticationError, [{message: I18n.t('errors.auth.wrong_credentials')}] unless user

      user
    end

    def generate_payload(refresh_token)
      {
          expired_at: refresh_token.expired_at_time.to_i,
          user_id: refresh_token.user_id,
          exp: (refresh_token.current_time + JWT_TOKEN_EXPIRED_MIN.minutes).to_i
      }
    end

    def validate_params(auth_params)
      raise AuthenticationError, [{message: I18n.t('errors.auth.credentials_required')}] if !auth_params[:username].present? && !auth_params[:password].present?
      raise AuthenticationError, [{message: I18n.t('errors.auth.blank_username')}] unless auth_params[:username].present?
      raise AuthenticationError, [{message: I18n.t('errors.auth.blank_password')}] unless auth_params[:password].present?
    end
  end
end
