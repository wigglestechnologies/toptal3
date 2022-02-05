module Admin
  class UserService
    include ExceptionHandler
    include ErrorsFormater
    include Validator

    attr_reader :params, :errors

    def initialize(params = {})
      @params = params
      @errors = []
    end

    def create
      validate_role if @params[:role]
      validate_password_match if @params[:password].present?
      @user = User.create(@params.merge(active: true).except(:password_confirmation))
      finish_operation
    end

    def update
      validate_password_match if @params[:password].present?
      validate_role if @params[:role]
      @user = get_user
      validate_admin_existance if @params[:role] == 'regular' || @params[:role] == 'manager'

      @user.update(@params.except(:password_confirmation))
      finish_operation
    end

    def show
      json_view(get_user)
    end

    def destroy
      get_user
      validate_admin_existance
      TokenStorage::AutoLoginTokenService.new(@user.id).delete_all_refresh_tokens
      @user.update(active: false)

      nil
    end

    private

    def get_user
      @user = User.where(id: @params[:id], active: true).first
      raise ActiveRecord::RecordNotFound, I18n.t("errors.user_not_found") if @user.nil?
      @user
    end

    def json_view(obj)
      obj.as_json(only: [:id, :email, :role, :full_name])
    end

    def finish_operation
      errors = fill_errors(@user)
      throw_exception(errors) if errors.any?
      json_view(@user)
    end

    def throw_exception(errors)
      raise ValidationError, errors
    end
  end
end
