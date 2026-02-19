class ProjectPolicy < ApplicationPolicy
  def index?   = true
  def show?    = true
  def new?     = user.admin? || user.estimator?
  def create?  = user.admin? || user.estimator?
  def edit?    = user.admin? || user.estimator?
  def update?  = user.admin? || user.estimator?
  def destroy? = false
  def discard? = user.admin?
  def duplicate? = user.admin? || user.estimator?

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.kept
    end
  end
end
