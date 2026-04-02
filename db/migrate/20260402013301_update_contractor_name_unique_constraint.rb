class UpdateContractorNameUniqueConstraint < ActiveRecord::Migration[8.0]
  def change
    remove_index :contractors, :name
    add_index :contractors, [:company_id, :name], unique: true
  end
end
