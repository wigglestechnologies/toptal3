class UsersController < ApplicationController
  before_action :validate_authentication, :init_service

  def update
    respond_json(@service.update)
  end

  def destroy
    respond_json(@service.destroy, :no_content)
  end

  def show
    respond_json(@service.show)
  end

  private

  def user_params
    params.permit(:email, :full_name, :password, :password_confirmation)
  end

  def init_service
    raise Pundit::NotAuthorizedError, I18n.t('errors.permission_denied') if @current_user.id != params[:id].to_i
    @service = Admin::UserService.new(user_params.merge(id: @current_user.id))
  end

end
