class ContractorsController < ApplicationController
  before_action :set_contractor, only: [ :show, :edit, :update, :destroy ]

  def index
    @contractors = policy_scope(Contractor).order(:name)
  end

  def show
    authorize @contractor
    @bid_submissions = @contractor.bid_submissions.kept.includes(:project).order(created_at: :desc)
  end

  def new
    @contractor = Contractor.new
    authorize @contractor
  end

  def create
    @contractor = Contractor.new(contractor_params)
    authorize @contractor

    if @contractor.save
      redirect_to @contractor, notice: "Contractor created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @contractor
  end

  def update
    authorize @contractor

    if @contractor.update(contractor_params)
      redirect_to @contractor, notice: "Contractor updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @contractor
    @contractor.destroy
    redirect_to contractors_path, notice: "Contractor deleted."
  end

  private

  def set_contractor
    @contractor = Contractor.find(params[:id])
  end

  def contractor_params
    params.require(:contractor).permit(:name, :contact_name, :email, :phone, :notes)
  end
end
