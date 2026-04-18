attributes :id, :first_name, :last_name, :email, :phone, :role, :contractor_id

node(:name) { |c| c.full_name }
