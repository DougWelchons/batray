class Project < ApplicationRecord
  include Discard::Model
  default_scope -> { undiscarded }

  belongs_to :company
  has_many :bid_submissions, dependent: :destroy, inverse_of: :project
  has_many :projects_classifications, dependent: :destroy
  has_many :classifications, through: :projects_classifications
  belongs_to :rebid_of, class_name: "Project", optional: true
  has_many :rebids, class_name: "Project", foreign_key: :rebid_of_id, dependent: :nullify

  accepts_nested_attributes_for :bid_submissions, allow_destroy: true, reject_if: :all_blank

  validates :name, presence: true
  validates :company_id, presence: true

  def earliest_bid_due_at
    if association(:bid_submissions).loaded?
      bid_submissions.map(&:bid_due_at).compact.min
    else
      bid_submissions.minimum(:bid_due_at)
    end
  end

  def bid_count
    if association(:bid_submissions).loaded?
      bid_submissions.size
    else
      bid_submissions.count
    end
  end

  def duplicate_for_rebid
    dup.tap do |p|
      p.rebid_of_id = id
      p.estimated_start_date = nil
      p.discarded_at = nil
    end
  end

  def project_status
    statuses = if association(:bid_submissions).loaded?
      bid_submissions.map(&:status)
    else
      bid_submissions.pluck(:status)
    end

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
    drafting_bids = if association(:bid_submissions).loaded?
      bid_submissions.select { |bs| bs.status == "drafting" }
    else
      bid_submissions.drafting
    end

    return nil unless drafting_bids.any?

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
    drafting_bids = if association(:bid_submissions).loaded?
      bid_submissions.select { |bs| bs.status == "drafting" }
    else
      bid_submissions.drafting
    end

    return nil unless drafting_bids.any?

    due = if association(:bid_submissions).loaded?
      drafting_bids.map(&:bid_due_at).compact.min
    else
      bid_submissions.drafting.minimum(:bid_due_at)
    end

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

    statuses = if association(:bid_submissions).loaded?
      subs.map(&:status)
    else
      subs.pluck(:status)
    end

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
