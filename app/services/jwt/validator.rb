module Jwt
  class Validator
    attr_reader :jwt_token

    def initialize(jwt_token)
      @jwt_token = jwt_token
      @valid = false
    end

    def call
      decode_token

      OpenStruct.new(valid?: true)
    rescue
      OpenStruct.new(valid?: false)
    end

    private
    def decode_token
      JWT.decode(jwt_token, secret_key, true, { algorithm: algorithm }.merge(options) )
    end

    def algorithm
      'HS256'
    end

    def options
      {}
    end

    def secret_key
      Rails.application.credentials.secret_key_base
    end
  end
end
