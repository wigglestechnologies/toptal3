module RefreshToken
  class Service
    include ExceptionHandler

    def initialize(client_headers = {})
      @client_headers = client_headers
      @bearer_token = client_headers[:bearer_token]
    end

    def refresh_token!
      result = RefreshToken::Validator.new(@bearer_token).call

      raise AuthenticationError, [{message: I18n.t('errors.unauthorized')}] if !result.valid? || result.user_id.nil?

      new_refresh_token = RefreshToken::GeneratorService.new.call

      refresh_token_service = TokenStorage::AutoLoginTokenService.new(result.user_id, @client_headers)
      refresh_token_service.delete_refresh_token(result.old_token)
      refresh_token_service.store_refresh_token(new_refresh_token)

      jwt_token = Jwt::Service.new(generate_payload(refresh_token_service), Jwt::Provider::Hmac.new).call

      {token: jwt_token, refresh_token: new_refresh_token}
    end

    def destroy_token!
      result = RefreshToken::Validator.new(@bearer_token).call
      raise AuthenticationError, [{message: I18n.t('errors.unauthorized')}] if !result.valid? || result.user_id.nil?
      TokenStorage::AutoLoginTokenService.new(result.user_id, @client_headers).delete_refresh_token(@bearer_token)

      {logged_out: true}
    end

    private

    def generate_payload(refresh_token)
      {
          expired_at: refresh_token.expired_at_time.to_i,
          user_id: refresh_token.user_id,
          exp: (refresh_token.current_time + JWT_TOKEN_EXPIRED_MIN.minutes).to_i
      }
    end
  end
end