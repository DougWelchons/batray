class Project < ApplicationRecord
  include Discard::Model

  has_many :bid_submissions, dependent: :destroy
  belongs_to :rebid_of, class_name: "Project", optional: true
  has_many :rebids, class_name: "Project", foreign_key: :rebid_of_id, dependent: :nullify

  accepts_nested_attributes_for :bid_submissions, allow_destroy: true, reject_if: :all_blank

  validates :name, presence: true

  scope :active, -> { kept }

  def duplicate_for_rebid
    dup.tap do |p|
      p.rebid_of_id = id
      p.estimated_start_date = nil
      p.discarded_at = nil
    end
  end
end
