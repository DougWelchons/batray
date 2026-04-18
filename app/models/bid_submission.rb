class BidSubmission < ApplicationRecord
  include Discard::Model
  default_scope -> { undiscarded }

  belongs_to :project, inverse_of: :bid_submissions
  belongs_to :contractor
  belongs_to :user, optional: true
  belongs_to :contact, optional: true

  # Access company through project
  delegate :company, to: :project

  enum :status, {
    drafting: "drafting",
    submitted: "submitted",
    awarded: "awarded",
    lost: "lost",
    withdrawn: "withdrawn",
    declined: "declined"
  }, default: :drafting

  # Validations
  validates :project, presence: true
  validates :contractor_id, presence: true
  validates :status, presence: true
  validates :probability_percent, numericality: { in: 0..100 }, allow_nil: true

  validates :submitted_value,
    numericality: { greater_than: 0 },
    if: -> { status_index >= status_index_for(:submitted) }

  validates :awarded_value,
    presence: true,
    numericality: { greater_than: 0 },
    if: :awarded?

  validates :award_decision_at,
    presence: true,
    if: -> { awarded? || lost? }

  validate :award_decision_after_bid_submitted

  # Uniqueness per spec
  validates :contractor_id, uniqueness: { scope: :project_id, message: "already has a bid for this project" }

  # Scopes for metrics
  scope :for_metrics, -> { where(status: [ :submitted, :awarded, :lost ]) }
  scope :won, -> { where(status: :awarded) }

  # Win rate helpers
  def self.win_rate
    metric_bids = for_metrics
    return nil if metric_bids.count.zero?
    (metric_bids.where(status: :awarded).count.to_f / metric_bids.count * 100).round(1)
  end

  def self.dollar_win_rate
    metric_bids = for_metrics
    total_submitted = metric_bids.sum(:submitted_value)
    return nil if total_submitted.zero?
    (metric_bids.where(status: :awarded).sum(:awarded_value) / total_submitted * 100).round(1)
  end

  def project_name
    project.name
  end

  def contractor_name
    contractor.name
  end

  def estimators_name
    user&.full_name
  end

  private

  def award_decision_after_bid_submitted
    return unless award_decision_at && bid_submitted_at
    if award_decision_at < bid_submitted_at
      errors.add(:award_decision_at, "must be on or after bid submitted date")
    end
  end

  def status_index
    self.class.statuses[status]
  end

  def status_index_for(name)
    self.class.statuses[name.to_s]
  end
end
