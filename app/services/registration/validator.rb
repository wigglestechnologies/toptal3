module Registration
  module Validator

    def validate_email_usage
      throw_exception([{message: I18n.t("errors.email_not_uniq")}]) if User.where(email: @params[:email], active: true).any?
    end

    def validate_old_invite
      old_registration_data = RegistrationDetail.where(email: @params[:email]).first
      old_registration_data.destroy! if old_registration_data.present?
    end

    def validate_token_and_password_match
      throw_exception([{message: I18n.t("errors.passwords_dont_match")}]) if @params[:password] != @params[:password_confirmation]
      valid_token?
    end

    private

    def valid_token?
      @reg_data = RegistrationDetail.where(token: @params[:token]).first
      errors = []

      if @reg_data.nil?
        errors = [{message: I18n.t("errors.invalid_token"), field: :token}]
      elsif @reg_data.valid_until < DateTime.now.utc
        errors = [{message: I18n.t("errors.registration_invalid_time"), field: :valid_until}]
      end

      throw_exception(errors) unless errors.empty?
      true
    end

  end
end
