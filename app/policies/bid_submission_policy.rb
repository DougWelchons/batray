class BidSubmissionPolicy < ApplicationPolicy
  def index?   = true
  def show?    = true
  def new?     = user.admin? || user.estimator?
  def create?  = user.admin? || user.estimator?
  def edit?    = user.admin? || (user.estimator? && record.user_id == user.id)
  def update?  = user.admin? || (user.estimator? && record.user_id == user.id)
  def destroy? = false
  def discard? = user.admin?

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.kept
    end
  end
end
