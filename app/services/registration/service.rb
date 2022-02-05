module Registration
  class Service
    include ExceptionHandler
    include ErrorsFormater
    include Validator

    attr_reader :params, :errors

    def initialize(params = {})
      @params = params
      @errors = []
      @params[:email]&.downcase! if @params[:email]
    end

    def call
      validate_email_usage
      token = generate_token_and_create_data(random_token)
      UserMailer.registration_invite(token, @params[:email]).deliver_now

      { email_sent: true }
    end

    def remove_expired_tokens
      RegistrationDetail.where("valid_until < ?", DateTime.now).destroy_all
    end

    private

    def generate_token_and_create_data(token)
      validate_old_invite
      create_registration_data(token)
      throw_exception(@errors) if @errors.any?

      token
    end

    def create_registration_data(reg_token)
      reg_data = RegistrationDetail.create(email: @params[:email], token: reg_token, valid_until: DateTime.now.utc + REGISTRATION_TOKENS_LIFE_TIME.hours)
      @errors.concat(fill_errors(reg_data))
    end

    def random_token
      SecureRandom.hex(16)
    end

    def throw_exception(errors)
      raise ValidationError, errors
    end
  end
end
