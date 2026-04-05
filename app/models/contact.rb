class Contact < ApplicationRecord
  belongs_to :contractor

  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone, presence: true, format: { with: /\A\+?[0-9\s\-]+\z/, message: "only allows numbers, spaces, and dashes" }
  validates_uniqueness_of :email, scope: :contractor_id, message: "should be unique per contractor"
end
