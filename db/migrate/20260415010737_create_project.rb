class CreateProject < ActiveRecord::Migration[8.0]
  def change
    create_table :projects, id: :uuid do |t|
      t.string :name
      t.string :street
      t.string :city
      t.string :state
      t.string :zip_code
      t.date :estimated_start_date
      t.integer :rebid_of_id
      t.datetime :discarded_at
      t.references :company, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
    add_index :projects, :name
    add_index :projects, :city
    add_index :projects, :rebid_of_id
    add_index :projects, :discarded_at
  end
end
