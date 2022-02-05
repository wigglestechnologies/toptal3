module Jwt
  module Provider
    class Hmac < Token
      DEFAULT_ALGORITHM = 'HS256'

      def algorithm
        super || DEFAULT_ALGORITHM
      end

      def provide_token(payload)
        encode(payload)
      end

      def decode_token(token)
        decode(token)
      end

      private
      def encode(payload)
        JWT.encode(payload, secret_key, algorithm, { typ: 'JWT' })
      end

      def decode(token)
        JWT.decode(token, secret_key, true, { algorithm: algorithm }.merge(options) )
      end
    end
  end
end
