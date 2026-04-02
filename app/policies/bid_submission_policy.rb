class BidSubmissionPolicy < ApplicationPolicy
  def index?   = true
  def show?    = same_company?
  def new?     = user.admin? || user.estimator?
  def create?  = user.admin? || user.estimator?
  def edit?    = same_company? && (user.admin? || (user.estimator? && record.user_id == user.id))
  def update?  = same_company? && (user.admin? || (user.estimator? && record.user_id == user.id))
  def destroy? = false
  def discard? = same_company? && user.admin?

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.joins(:project).where(projects: { company_id: user.company_id }).kept
    end
  end

  private

  def same_company?
    record.project.company_id == user.company_id
  end
end
