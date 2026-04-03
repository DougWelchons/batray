class Api::V1::CurrentUsersController < Api::V1::BaseController
  def show
    render json: current_user.as_json(only: [:id, :name, :email, :role, :created_at, :updated_at])
  end
end
