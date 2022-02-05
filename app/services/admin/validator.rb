module Admin
  module Validator

    def validate_email_format
      throw_exception([{message: I18n.t("errors.invalid_email")}]) if @params[:email].nil? ||
          @params[:email].length > STRING_MAX_LIMIT ||
          !(@params[:email] =~ REGEX_EMAIL)
    end

    def validate_password_match
      throw_exception([{message: I18n.t("errors.passwords_dont_match")}]) if @params[:password] != @params[:password_confirmation]
    end

    def validate_role
      throw_exception([{message: I18n.t("errors.invalid_role")}]) unless ['regular', 'manager', 'admin'].include?(@params[:role])
    end

    def validate_admin_existance
      if @user.admin?
        one_admin_remained = User.where(role: 'admin', active: true).count == 1
        raise Pundit::NotAuthorizedError, I18n.t('errors.admin_destroy_denied') if one_admin_remained
      end
      true
    end
  end
end
