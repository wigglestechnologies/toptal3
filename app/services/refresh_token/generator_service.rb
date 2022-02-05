module RefreshToken
  class GeneratorService
    def call
      generate_uuid
    end

    private
    def generate_uuid
      SecureRandom.uuid
    end
  end
end
