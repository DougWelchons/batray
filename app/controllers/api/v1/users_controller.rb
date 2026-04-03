class Api::V1::UsersController < Api::V1::BaseController
  before_action :set_user, only: [:show, :update, :destroy]

  def index
    @users = @company.users
    render json: @users.as_json(only: [:id, :name, :email, :role, :created_at, :updated_at])
  end

  def show
    render json: @user.as_json(only: [:id, :name, :email, :role, :created_at, :updated_at])
  end

  def create
    @user = @company.users.build(user_params)

    if @user.save
      render json: @user.as_json(only: [:id, :name, :email, :role, :created_at, :updated_at]), status: :created
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @user.update(user_params)
      render json: @user.as_json(only: [:id, :name, :email, :role, :created_at, :updated_at])
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy
    head :no_content
  end

  private

  def set_user
    @user = @company.users.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email, :role, :password, :password_confirmation)
  end
end
