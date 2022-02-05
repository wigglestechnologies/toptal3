class Admin::UsersController < ApplicationController
  before_action :validate_authentication, :init_service
  before_action :set_user, only: [:show, :update, :destroy]
  before_action :authorize_user, except: [:index]

  alias_method :current_user, :current_account

  def create
    respond_json(@service.create, :created)
  end

  def update
    respond_json(@service.update)
  end

  def destroy
    respond_json(@service.destroy, :no_content)
  end

  def index
    @users_list = FilterService.new(policy_scope(User), filter_params, USER_FIELDS).call
    data = @users_list.as_json(:only => [:id, :full_name, :email, :role])

    respond_json({data: data, total_count: @users_list.total_count})
  end

  def show
    respond_json(@service.show)
  end

  private

  def authorize_user
    fixed_params = ['regular', 'manager', 'admin'].include?(params[:role]) ?  user_params.except(:password_confirmation) : user_params.except(:role, :password_confirmation)
    authorize @user || User.new(fixed_params)
  end

  # Only allow a trusted parameter "white list" through.
  def user_params
    params.permit(policy(@current_user || User.new).permitted_attributes)
  end

  def init_service
    @service = Admin::UserService.new(user_params)
  end

  def set_user
    @user = User.where(id: params[:id], active: true).first
    raise Pundit::NotAuthorizedError,  I18n.t('errors.permission_denied') if role_change_check
    raise ActiveRecord::RecordNotFound, I18n.t("errors.user_not_found") if @user.nil?
  end

  def role_change_check
    (@user.nil? && @current_user&.regular?) || (!@user&.admin? && !@current_user&.admin? && params[:role] == 'admin') || (!@current_user&.admin? && params[:role] == 'admin')
  end

  def filter_params
    params.permit(:page, :page_limit, :filters)
  end

end
