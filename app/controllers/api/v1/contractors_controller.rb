class Api::V1::ContractorsController < Api::V1::BaseController
  before_action :set_contractor, only: [ :show, :update, :destroy ]

  def index
    @contractors = @company.contractors.includes(:contacts, bid_submissions: [ :project, :contractor, :user ])
  end

  def show
  end

  def create
    @contractor = @company.contractors.build(contractor_params)

    if @contractor.save
      render :show, status: :created
    else
      render json: { errors: @contractor.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @contractor.update(contractor_params)
      render :show
    else
      render json: { errors: @contractor.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @contractor.destroy
    head :no_content
  end

  private

  def set_contractor
    @contractor = @company.contractors.includes(:contacts, bid_submissions: [ :project, :contractor, :user ]).find(params[:id])
  end

  def contractor_params
    params.require(:contractor).permit(
      :name,
      :contact_name,
      :email,
      :phone,
      :notes
    )
  end
end
