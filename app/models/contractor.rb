class Contractor < ApplicationRecord
  belongs_to :company
  has_many :bid_submissions, dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: :company_id, case_sensitive: false }
  validates :company_id, presence: true

  def display_name
    name
  end
end
