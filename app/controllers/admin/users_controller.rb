module Admin
  class UsersController < ApplicationController
    before_action :require_admin!
    before_action :set_user, only: [ :show, :edit, :update, :destroy ]

    def index
      @users = User.order(:name)
    end

    def show; end

    def new
      @user = User.new
    end

    def create
      @user = User.new(user_params)
      if @user.save
        redirect_to admin_users_path, notice: "User created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @user.update(update_params)
        redirect_to admin_users_path, notice: "User updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @user.destroy
      redirect_to admin_users_path, notice: "User deleted."
    end

    private

    def require_admin!
      redirect_to root_path, alert: "Access denied." unless current_user.admin?
    end

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:name, :email, :role, :password, :password_confirmation)
    end

    def update_params
      p = params.require(:user).permit(:name, :email, :role, :password, :password_confirmation)
      p.delete(:password) if p[:password].blank?
      p.delete(:password_confirmation) if p[:password_confirmation].blank?
      p
    end
  end
end
