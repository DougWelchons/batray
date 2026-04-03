class SpaController < ApplicationController
  before_action :authenticate_user!

  def index
    # Single page app entry point - all routing handled by React Router
  end
end
