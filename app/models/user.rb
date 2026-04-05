class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :role, { admin: "admin", estimator: "estimator", viewer: "viewer" }, default: :estimator

  belongs_to :company
  has_many :bid_submissions, dependent: :destroy

  validates :name, presence: true
  validates :role, presence: true
  validates :company_id, presence: true

  def full_name
    name
  end
end
