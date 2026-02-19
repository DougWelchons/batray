class Contractor < ApplicationRecord
  has_many :bid_submissions, dependent: :destroy

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  def display_name
    name
  end
end
