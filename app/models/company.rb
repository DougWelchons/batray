class Company < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :projects, dependent: :destroy
  has_many :contractors, dependent: :destroy

  validates :name, presence: true

  scope :active, -> { where(active: true) }
end
