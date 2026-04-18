class Classification < ApplicationRecord
  belongs_to :company
  has_many :projects_classifications, dependent: :destroy
  has_many :projects, through: :projects_classifications, class_name: "Project"

  validates :name, presence: true
  validates :name, uniqueness: { scope: :company_id, case_sensitive: false }
end
