class ContractorPolicy < ApplicationPolicy
  def index?   = true
  def show?    = true
  def new?     = user.admin? || user.estimator?
  def create?  = user.admin? || user.estimator?
  def edit?    = user.admin? || user.estimator?
  def update?  = user.admin? || user.estimator?
  def destroy? = user.admin?

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end
