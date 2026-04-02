class ChangeUserRoleToString < ActiveRecord::Migration[8.0]
  def up
    # Add temporary column
    add_column :users, :role_string, :string

    # Convert existing integer values to string values
    User.reset_column_information
    User.find_each do |user|
      case user.role_before_type_cast
      when 0
        user.update_column(:role_string, "admin")
      when 1
        user.update_column(:role_string, "estimator")
      when 2
        user.update_column(:role_string, "viewer")
      end
    end

    # Remove old column and rename new one
    remove_column :users, :role
    rename_column :users, :role_string, :role

    # Set default
    change_column_default :users, :role, "estimator"
  end

  def down
    # Add temporary integer column
    add_column :users, :role_integer, :integer

    # Convert string values back to integers
    User.reset_column_information
    User.find_each do |user|
      case user.role
      when "admin"
        user.update_column(:role_integer, 0)
      when "estimator"
        user.update_column(:role_integer, 1)
      when "viewer"
        user.update_column(:role_integer, 2)
      end
    end

    # Remove string column and rename integer one
    remove_column :users, :role
    rename_column :users, :role_integer, :role

    # Set default
    change_column_default :users, :role, 1
  end
end
