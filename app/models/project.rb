class Project < ApplicationRecord
  include Discard::Model
  default_scope -> { undiscarded }

  belongs_to :company
  has_many :bid_submissions, dependent: :destroy, inverse_of: :project
  belongs_to :rebid_of, class_name: "Project", optional: true
  has_many :rebids, class_name: "Project", foreign_key: :rebid_of_id, dependent: :nullify

  accepts_nested_attributes_for :bid_submissions, allow_destroy: true, reject_if: :all_blank

  validates :name, presence: true
  validates :company_id, presence: true

  def earliest_bid_due_at
    bid_submissions.minimum(:bid_due_at)
  end

  def bid_count
    bid_submissions.count
  end

  def duplicate_for_rebid
    dup.tap do |p|
      p.rebid_of_id = id
      p.estimated_start_date = nil
      p.discarded_at = nil
    end
  end

  def project_status
    statuses = bid_submissions.pluck(:status)

    if statuses.include?("awarded")
      "awarded"
    elsif statuses.all? { |s| %w[lost withdrawn declined].include?(s) } && statuses.any? { |s| s == "lost" }
      "lost"
    elsif statuses.any? { |s| s == "drafting" }
      "drafting"
    elsif statuses.any? { |s| %w[submitted].include?(s) }
      "submitted"
    else
      "inactive"
    end
  end

  def project_due_status
    return nil unless bid_submissions.drafting.any?

    if earliest_bid_due_at.nil?
      "no-due-date"
    elsif earliest_bid_due_at < Time.current
      "overdue"
    elsif earliest_bid_due_at <= 2.days.from_now
      "due-soon"
    else
      "on-track"
    end
  end


  def bid_due_urgency_class
    return nil unless bid_submissions.drafting.any?

    due = bid_submissions.drafting.minimum(:bid_due_at)
    return nil unless due

    days = (due.to_date - Date.today).to_i
    if days < 0
      "bid-due--overdue"
    elsif days <= 2
      "bid-due--warning"
    end
  end

  def bid_status_class
    subs = bid_submissions
    return "project-row--drafting" if subs.none?

    statuses = subs.pluck(:status)
    if statuses.include?("awarded")
      "project-row--awarded"
    elsif statuses.all? { |s| %w[lost withdrawn declined].include?(s) } && statuses.any? { |s| s == "lost" }
      "project-row--lost"
    elsif statuses.any? { |s| s == "drafting" }
      "project-row--drafting"
    elsif statuses.any? { |s| %w[submitted].include?(s) }
      "project-row--submitted"
    else
      "project-row--inactive"
    end
  end
end
