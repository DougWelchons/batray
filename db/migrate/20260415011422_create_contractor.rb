class CreateContractor < ActiveRecord::Migration[8.0]
  def change
    create_table :contractors, id: :uuid do |t|
      t.string :name
      t.string :street
      t.string :city
      t.string :state
      t.string :zip_code
      t.string :phone
      t.string :notes
      t.datetime :discarded_at
      t.references :company, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end

    add_index :contractors, :discarded_at
    add_index :contractors, [ :company_id, :name ], unique: true
  end
end
