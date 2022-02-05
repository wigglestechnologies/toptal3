module TokenStorage
  class AutoLoginTokenService
    attr_reader :user_id, :data, :current_time, :expired_at_time, :model_name

    def initialize(user_id = nil, data = {})
      @user_id = user_id
      @data = data
      @current_time = DateTime.now
    end

    def store_refresh_token(token)
      AllowedToken.create!(stored_data(token))
    end

    def find_refresh_token(token)
      AllowedToken.where(encrypted_token: encrypted_token(token)).first
    end

    def delete_refresh_token(old_token)
      AllowedToken.where(encrypted_token: encrypted_token(old_token)).destroy_all
    end

    def delete_all_refresh_tokens
      AllowedToken.where(user_id: @user_id).destroy_all
    end

    def expired_at_time
      current_time + REFRESH_TOKEN_EXPIRED_MIN.minutes
    end

    def destroy_expired_tokens
      AllowedToken.where("expired_at <= ?", current_time).destroy_all

    rescue => e
      Rails.logger.error("destroy_expired_tokens ERROR #{e}")
    end

    private
    def stored_data(token)
      client = DeviceDetector.new(data[:user_agent])

      {
          encrypted_token: encrypted_token(token),
          platform: client.device_type,
          user_id: user_id,
          ip: data[:ip],
          os: client.os_name,
          browser: client.name,
          user_agent: data[:user_agent],
          expired_at: expired_at_time,
          created_at: current_time,
          updated_at: current_time
      }
    end

    def encrypted_token(token)
      Digest::MD5.hexdigest(token)
    end
  end
end
