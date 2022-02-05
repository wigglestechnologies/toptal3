module RefreshToken
  class Validator
    attr_accessor :refresh_token

    attr_reader :valid, :user_id, :old_token

    def initialize(refresh_token)
      @refresh_token = refresh_token
    end

    def call
      token_data = TokenStorage::AutoLoginTokenService.new(nil, {}).find_refresh_token(refresh_token)
      Rails.logger.error("token_data #{token_data}, token_data.user_id #{token_data&.user_id}")
      OpenStruct.new(valid?: valid_expired_date?(token_data), user_id: token_data.user_id, old_token: refresh_token)
    rescue => e
      OpenStruct.new(valid?: false, user_id: nil).tap do |_|
        Rails.logger.error("Method: #{ __method__ }, Error: #{ e }")
      end
    end

    private
    def valid_expired_date?(token_data)
      token_data.present? && token_data.expired_at > DateTime.now
    end
  end
end