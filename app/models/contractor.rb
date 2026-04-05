class Contractor < ApplicationRecord
  belongs_to :company
  has_many :bid_submissions, dependent: :destroy
  has_many :contacts, dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: :company_id, case_sensitive: false }
  validates :company_id, presence: true

  def display_name
    name
  end

  def total_bid_submissions
    bid_submissions.count
  end
end
