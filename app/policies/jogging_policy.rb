class JoggingPolicy < ApplicationPolicy
  include ExceptionHandler

  class Scope < Scope
    def resolve
      if user.admin?
        scope.joins(:user).where('users.active = ?', true)
      else
        scope.where(user_id: user.id)
      end
    end
  end

  def update?
    has_permission?
  end

  def show?
    has_permission?
  end

  def destroy?
    has_permission?
  end

  def permitted_attributes
    user.admin? ? [:id, :user_id, :date, :duration, :lon, :lat, :distance, :page, :page_limit] : [:id, :date, :duration, :lon, :lat, :distance, :page, :page_limit]
  end

  private

  def has_permission?
    raise Pundit::NotAuthorizedError, I18n.t('errors.permission_denied') if user.id != record.user_id && !user.admin?
    true
  end

end