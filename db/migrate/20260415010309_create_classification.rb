class CreateClassification < ActiveRecord::Migration[8.0]
  def change
    create_table :classifications, id: :uuid do |t|
      t.string :name
      t.references :company, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
    add_index :classifications, :name
    add_index :classifications, [ :company_id, :name ], unique: true
  end
end
