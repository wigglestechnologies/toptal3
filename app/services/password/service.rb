module Password
  class Service
    include ErrorsFormater
    include ExceptionHandler
    include Password::Validator

    attr_reader :params

    def initialize(params = {})
      @params = params
      @params[:email]&.downcase! if @params[:email]
    end

    # generating password token and sending proper email to customer
    # response is always success
    def generate_password_token
      validate_email_format
      @user = User.where(email: @params[:email], active: true).first
      generate_password_token! unless @user.nil?

      { email_sent: true }
    end

    # change password through token, which was sent to email
    def call
      validate_token_and_password_match
      reset_password

      password_change_finished
    end

    private
    # Generating pass token and send to email
    def generate_password_token!
      @user.update!(reset_password_token: generate_token, reset_password_token_expires_at: DateTime.now.utc + RESET_PASSWORD_TOKENS_LIFE_TIME.hours)
      UserMailer.reset_password_email(@user).deliver_now
    end

    def reset_password
      @user = User.where(reset_password_token: @params[:token]).where('reset_password_token_expires_at > ?', DateTime.now.utc).first
      throw_exception([{"message": I18n.t('errors.token_expired')}]) if @user.nil?

      invalidate_all_session(@user&.id)
      @user.update(reset_password_token: nil, password: @params[:password])
      errors = fill_errors(@user)
      throw_exception(errors) if errors.any?
    end

    def invalidate_all_session(user_id)
      TokenStorage::AutoLoginTokenService.new(user_id).delete_all_refresh_tokens
    end

    # Returns data for AUTO LOGIN
    def password_change_finished
      UserMailer.password_change(@user).deliver_now
      { username: @user.email, password: @params[:password], success?: true }
    end

    def generate_token
      SecureRandom.hex(10)
    end

    def throw_exception(errors)
      raise ValidationError, errors
    end
  end
end
