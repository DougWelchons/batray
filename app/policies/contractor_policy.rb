class ContractorPolicy < ApplicationPolicy
  def index?   = true
  def show?    = record.company_id == user.company_id
  def new?     = user.admin? || user.estimator?
  def create?  = user.admin? || user.estimator?
  def edit?    = same_company? && (user.admin? || user.estimator?)
  def update?  = same_company? && (user.admin? || user.estimator?)
  def destroy? = same_company? && user.admin?

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope_to_company
    end
  end

  private

  def same_company?
    record.company_id == user.company_id
  end
end
