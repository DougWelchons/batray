class Api::V1::CurrentUsersController < Api::V1::BaseController
  def show
    @user = current_user
  end
end
