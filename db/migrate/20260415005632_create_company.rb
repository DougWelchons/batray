class CreateCompany < ActiveRecord::Migration[8.0]
  def change
    create_table :companies, id: :uuid do |t|
      t.string :name
      t.string :street
      t.string :city
      t.string :zip_code
      t.string :state
      t.string :phone
      t.boolean :active

      t.timestamps
    end
    add_index :companies, :name, unique: true
  end
end
