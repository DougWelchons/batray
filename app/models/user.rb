class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :role, { admin: 0, estimator: 1, viewer: 2 }, default: :estimator

  has_many :bid_submissions, dependent: :destroy

  validates :name, presence: true
  validates :role, presence: true
end
