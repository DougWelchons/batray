class AddCompanyToProjects < ActiveRecord::Migration[8.0]
  def change
    add_reference :projects, :company, foreign_key: true

    # Assign all existing projects to the default company
    reversible do |dir|
      dir.up do
        default_company = Company.first
        Project.unscoped.update_all(company_id: default_company.id) if default_company
      end
    end

    # Now make it not null
    change_column_null :projects, :company_id, false
  end
end
