class Contact < ApplicationRecord
  include Discard::Model
  default_scope -> { undiscarded }

  belongs_to :contractor

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone, presence: true, format: { with: /\A\+?[0-9\s\-]+\z/, message: "only allows numbers, spaces, and dashes" }
  validates :email, uniqueness: { scope: :contractor_id, message: "should be unique per contractor" }

  def full_name
    "#{first_name} #{last_name}"
  end
end
