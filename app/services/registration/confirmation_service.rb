module Registration
  class ConfirmationService
    include ExceptionHandler
    include ErrorsFormater
    include Validator

    def initialize(params)
      @params = params
      @params[:email]&.downcase! if @params[:email]
    end

    def call
      validate_token_and_password_match
      create_user
      @reg_data.destroy!

      UserMailer.registration_confirmed(@user).deliver_now
      @user.as_json(only: [:full_name, :email, :role])
    end

    def throw_exception(errors)
      raise ValidationError, errors
    end
    
    private
    def create_user
      validate_email_usage
      params_to_create = @params.merge(active: true, email: @reg_data&.email)
      @user = User.create(params_to_create.except(:password_confirmation, :token))
      errors = fill_errors(@user)
      throw_exception(errors) unless errors.empty?
    end
  end
end
