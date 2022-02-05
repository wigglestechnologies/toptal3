module Password
  module Validator

    def validate_email_format
      throw_exception([{message: I18n.t("errors.invalid_email")}]) if @params[:email].nil? ||
                                                                      @params[:email].length > 255 ||
                                                                      !(@params[:email] =~ /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i)
    end


    def validate_token_and_password_match
      throw_exception([{message: I18n.t("errors.passwords_dont_match")}]) if @params[:password] != @params[:password_confirmation]
    end
  end
end
