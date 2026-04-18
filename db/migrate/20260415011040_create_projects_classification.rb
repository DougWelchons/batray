class CreateProjectsClassification < ActiveRecord::Migration[8.0]
  def change
    create_table :projects_classifications, id: :uuid do |t|
      t.references :project, null: false, foreign_key: true, type: :uuid
      t.references :classification, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
