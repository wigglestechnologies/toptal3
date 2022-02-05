module Jwt
  class Token
    attr_accessor :secret_key, :algorithm, :options

    def secret_key
      @secret_key || Rails.application.credentials.secret_key_base
    end

    def provide_token(_)
      raise "You must define #{ __method__ }"
    end

    def decode_token(_)
      raise "You must define #{ __method__ }"
    end

    def options
      @options || {}
    end
  end
end
