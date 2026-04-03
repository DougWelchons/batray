class Api::V1::BaseController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_user!
  before_action :set_company

  respond_to :json

  private

  def set_company
    @company = current_user.company
  end
end
