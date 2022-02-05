class JoggingsController < ApplicationController

  before_action :validate_authentication, :init_jogging_service
  before_action :set_jogging, only: [:show, :update, :destroy]
  before_action :authorize_jogging, except: [:create, :index]

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

  def show
    respond_json(@service.show)
  end

  def index
    @jogging_list = FilterService.new(policy_scope(Jogging), filter_params, JOGGING_FIELDS, 'date DESC').call
    data = Joggings::Service.new.json_view(@jogging_list)
    respond_json({data: data, total_count: @jogging_list.total_count})
  end

  private

  def init_jogging_service
    @service = Joggings::Service.new(jogging_params, @current_user)
  end

  def set_jogging
    @jogging = Jogging.includes(:weather).find(params[:id])
  rescue
    raise Pundit::NotAuthorizedError, I18n.t('errors.permission_denied') if @current_user.regular? ||  @current_user.manager?
    raise raise ActiveRecord::RecordNotFound, I18n.t("errors.jogging_not_found")
  end

  def authorize_jogging
    authorize @jogging
  end

  # Only allow a trusted parameter "white list" through.
  def jogging_params
    params.permit(policy(@jogging || Jogging.new).permitted_attributes)
  end

  def filter_params
    params.permit(:page, :page_limit, :filters)
  end
end
