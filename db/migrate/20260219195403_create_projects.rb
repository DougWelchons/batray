class CreateProjects < ActiveRecord::Migration[8.2]
  def change
    create_table :projects do |t|
      t.string :name, null: false
      t.string :location
      t.string :project_type
      t.date :estimated_start_date
      t.integer :rebid_of_id
      t.datetime :discarded_at

      t.timestamps
    end

    add_index :projects, :rebid_of_id
    add_index :projects, :discarded_at
  end
end
