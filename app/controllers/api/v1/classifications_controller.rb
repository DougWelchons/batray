class Api::V1::ClassificationsController < Api::V1::BaseController
  def index
    @classifications = @company.classifications.order(:name)
  end
end
