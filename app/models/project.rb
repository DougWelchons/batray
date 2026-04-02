class Project < ApplicationRecord
  include Discard::Model

  belongs_to :company
  has_many :bid_submissions, dependent: :destroy, inverse_of: :project
  belongs_to :rebid_of, class_name: "Project", optional: true
  has_many :rebids, class_name: "Project", foreign_key: :rebid_of_id, dependent: :nullify

  accepts_nested_attributes_for :bid_submissions, allow_destroy: true, reject_if: :all_blank

  validates :name, presence: true
  validates :company_id, presence: true

  scope :active, -> { kept }

  def earliest_bid_due_at
    bid_submissions.kept.minimum(:bid_due_at)
  end

  def bid_due_urgency_class
    return nil unless bid_submissions.kept.drafting.any?

    due = bid_submissions.kept.drafting.minimum(:bid_due_at)
    return nil unless due

    days = (due.to_date - Date.today).to_i
    if days < 0
      "bid-due--overdue"
    elsif days <= 2
      "bid-due--warning"
    end
  end

  def bid_status_class
    subs = bid_submissions.kept
    return "project-row--drafting" if subs.none?

    statuses = subs.pluck(:status)
    if statuses.include?("awarded")
      "project-row--awarded"
    elsif statuses.all? { |s| %w[lost withdrawn declined].include?(s) } && statuses.any? { |s| s == "lost" }
      "project-row--lost"
    elsif statuses.any? { |s| %w[submitted].include?(s) }
      "project-row--submitted"
    elsif statuses.any? { |s| s == "drafting" }
      "project-row--drafting"
    else
      "project-row--inactive"
    end
  end

  def duplicate_for_rebid
    dup.tap do |p|
      p.rebid_of_id = id
      p.estimated_start_date = nil
      p.discarded_at = nil
    end
  end
end
