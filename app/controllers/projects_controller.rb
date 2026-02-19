class ProjectsController < ApplicationController
  before_action :set_project, only: [ :show, :edit, :update, :discard, :duplicate ]

  def index
    @projects = policy_scope(Project).order(created_at: :desc)
  end

  def show
    authorize @project
    @bid_submissions = @project.bid_submissions.kept.includes(:contractor, :user)
  end

  def new
    @project = Project.new
    @project.bid_submissions.build
    authorize @project
  end

  def create
    @project = Project.new(project_params)
    authorize @project

    if @project.save
      redirect_to @project, notice: "Project created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @project
  end

  def update
    authorize @project

    if @project.update(project_params)
      redirect_to @project, notice: "Project updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def discard
    authorize @project
    @project.discard
    redirect_to projects_path, notice: "Project archived."
  end

  def duplicate
    authorize @project, :duplicate?

    new_project = @project.duplicate_for_rebid
    if new_project.save
      @project.bid_submissions.kept.each do |bid|
        new_project.bid_submissions.create!(
          contractor_id: bid.contractor_id,
          user_id: bid.user_id,
          status: :drafting,
          probability_percent: bid.probability_percent,
          included_fire_alarm: bid.included_fire_alarm,
          included_low_voltage: bid.included_low_voltage,
          base_scope_description: bid.base_scope_description
        )
      end
      redirect_to new_project, notice: "Project duplicated as rebid."
    else
      redirect_to @project, alert: "Could not duplicate project."
    end
  end

  private

  def set_project
    @project = Project.kept.find(params[:id])
  end

  def project_params
    params.require(:project).permit(
      :name, :location, :project_type, :estimated_start_date, :rebid_of_id,
      bid_submissions_attributes: [
        :id, :contractor_id, :user_id, :status, :bid_submitted_at, :bid_due_at,
        :submitted_value, :probability_percent, :included_fire_alarm,
        :included_low_voltage, :base_scope_description, :notes, :_destroy
      ]
    )
  end
end
