attributes :id, :first_name, :last_name, :email, :role, :created_at, :updated_at

node(:name) { |u| u.full_name }
