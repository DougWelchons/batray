class AddCompanyToUsers < ActiveRecord::Migration[8.0]
  def change
    add_reference :users, :company, foreign_key: true

    # Create a default company if none exists
    reversible do |dir|
      dir.up do
        if Company.count.zero?
          default_company = Company.create!(
            name: "Default Company",
            subdomain: "default",
            active: true
          )

          # Assign all existing users to the default company
          User.unscoped.update_all(company_id: default_company.id)
        end
      end
    end

    # Now make it not null
    change_column_null :users, :company_id, false
  end
end
