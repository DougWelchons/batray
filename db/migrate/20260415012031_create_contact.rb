class CreateContact < ActiveRecord::Migration[8.0]
  def change
    create_table :contacts, id: :uuid do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :phone
      t.string :role
      t.string :notes
      t.datetime :discarded_at
      t.references :contractor, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end

    add_index :contacts, :discarded_at
  end
end
