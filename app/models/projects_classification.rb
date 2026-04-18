class ProjectsClassification < ApplicationRecord
  belongs_to :project
  belongs_to :classification
end
