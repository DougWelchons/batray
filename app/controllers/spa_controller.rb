class SpaController < ApplicationController
  layout "spa"
  before_action :authenticate_user!

  def index
  end
end
