class UserPolicy < ApplicationPolicy
  include ExceptionHandler
  class Scope < Scope
    def resolve
      if user&.admin?
        scope.where(active: true)
      elsif user&.manager?
        scope.where(active: true).where.not(role: 'admin')
      else
        raise Pundit::NotAuthorizedError, I18n.t('errors.permission_denied')
      end
    end
  end

  def create?
    raise Pundit::NotAuthorizedError, I18n.t('errors.permission_denied') unless has_creation_permission
    user&.admin? || user&.manager?
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
    [:id, :full_name, :role, :email, :password, :password_confirmation, :page, :page_limit]
  end

  private

  def has_permission?
    allowed = (user&.id == record&.id && !user.regular?) || user&.admin? || (user&.manager? && (record&.role == 'regular' || record&.role == 'manager'))
    raise Pundit::NotAuthorizedError, I18n.t('errors.permission_denied') unless allowed
    allowed
  end

  def has_creation_permission
    user&.admin? || (user&.manager? && (record&.role.nil? || record&.role == 'regular' || record&.role == 'manager'))
  end
end