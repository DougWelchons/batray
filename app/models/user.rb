class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :role, { admin: "admin", estimator: "estimator", viewer: "viewer" }, default: :estimator

  belongs_to :company
  has_many :bid_submissions, dependent: :destroy

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :role, presence: true
  validates :company_id, presence: true

  def full_name
    "#{first_name} #{last_name}"
  end
end
