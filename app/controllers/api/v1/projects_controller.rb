class Api::V1::ProjectsController < Api::V1::BaseController
  before_action :set_project, only: [:show, :update, :destroy]

  def index
    @projects = @company.projects.kept
    render json: @projects.as_json(only: [:id, :name, :location, :project_type, :estimated_start_date, :rebid_of_id, :created_at, :updated_at])
  end

  def show
    render json: @project.as_json(only: [:id, :name, :location, :project_type, :estimated_start_date, :rebid_of_id, :created_at, :updated_at])
  end

  def create
    @project = @company.projects.build(project_params)

    if @project.save
      render json: @project.as_json(only: [:id, :name, :location, :project_type, :estimated_start_date, :rebid_of_id, :created_at, :updated_at]), status: :created
    else
      render json: { errors: @project.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @project.update(project_params)
      render json: @project.as_json(only: [:id, :name, :location, :project_type, :estimated_start_date, :rebid_of_id, :created_at, :updated_at])
    else
      render json: { errors: @project.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @project.discard
    head :no_content
  end

  private

  def set_project
    @project = @company.projects.kept.find(params[:id])
  end

  def project_params
    params.require(:project).permit(
      :name,
      :location,
      :project_type,
      :estimated_start_date,
      :rebid_of_id
    )
  end
end
