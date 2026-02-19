class CreateContractors < ActiveRecord::Migration[8.2]
  def change
    create_table :contractors do |t|
      t.string :name
      t.string :contact_name
      t.string :email
      t.string :phone
      t.text :notes

      t.timestamps
    end
    add_index :contractors, :name, unique: true
  end
end
