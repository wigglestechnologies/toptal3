module ExceptionHandler
  extend ActiveSupport::Concern
  include ActiveSupport::Rescuable

  class ForbiddenAction < StandardError; end
  class InvalidToken < StandardError; end
  class AuthenticationError < StandardError; end
  class MissingToken < StandardError; end
  class ValidationError < StandardError; end

  included do
    rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_request
    rescue_from ExceptionHandler::InvalidToken, with: :unprocessable_request
    rescue_from ExceptionHandler::AuthenticationError, with: :unauthorized_request
    rescue_from ExceptionHandler::MissingToken, with: :unprocessable_request
    rescue_from ExceptionHandler::ValidationError, with: :validation_failure
    rescue_from Pundit::NotAuthorizedError, with: :forbidden_request
    rescue_from ActiveRecord::StatementInvalid, with: :db_query_failure

    rescue_from ActiveRecord::RecordNotFound do |e|
      respond_json({ errors: [{message: e.message}] }, :not_found)
    end
    rescue_from ActiveRecord::RecordNotUnique do
      respond_json({ errors: [{message:  I18n.t("errors.data_not_uniq")}] }, :unprocessable_entity)
    end
  end

  private

  def unauthorized_request(e)
    respond_json({errors: e.message}, :unauthorized)
  end

  def forbidden_request(e)
    respond_json({errors: [{message: e.message}]}, :forbidden)
  end

  def unprocessable_request(e)
    respond_json({errors: e.message}, :unprocessable_entity)
  end

  def validation_failure(e)
    respond_json({errors: e.message}, :bad_request)
  end

  def db_query_failure
    respond_json({errors: [message: I18n.t('errors.invalid_filter_format')]}, :bad_request)
  end
end