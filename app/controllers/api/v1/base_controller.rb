class Api::V1::BaseController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_user!
  before_action :set_company

  respond_to :json

  after_action :set_flash_headers

  private

  def set_flash_headers
    response.set_header("X-Flash-Notice", flash[:notice]) if flash[:notice].present?
    response.set_header("X-Flash-Alert", flash[:alert]) if flash[:alert].present?
  end

  def set_company
    @company = current_user.company
  end
end
