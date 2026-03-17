class ProjectsController < ApplicationController
  before_action :set_project, only: [ :show, :edit, :update, :discard, :duplicate ]

  SORTABLE_COLUMNS = %w[name location project_type estimated_start_date created_at bid_due_at bid_count].freeze

  VALID_STATUSES = %w[drafting submitted awarded lost withdrawn declined].freeze

  def index
    @sort_col = SORTABLE_COLUMNS.include?(params[:sort]) ? params[:sort] : "bid_due_at"
    @sort_dir = params[:dir] == "asc" ? "asc" : "desc"

    base = policy_scope(Project)

    # Filtering
    if params[:status].present? && VALID_STATUSES.include?(params[:status])
      base = base.joins(:bid_submissions)
                 .where(bid_submissions: { status: params[:status], discarded_at: nil })
                 .distinct
    end

    if params[:project_type].present?
      base = base.where(project_type: params[:project_type])
    end

    if params[:location].present?
      base = base.where("projects.location ILIKE ?", "%#{params[:location].strip}%")
    end

    if params[:year].present? && params[:year].match?(/\A\d{4}\z/)
      year = params[:year].to_i
      base = base.where(created_at: Date.new(year).beginning_of_year..Date.new(year).end_of_year)
    end

    # Populate filter option lists from the current (unfiltered) base for dropdowns
    unfiltered = policy_scope(Project)
    @filter_types = unfiltered.where.not(project_type: [nil, ""]).distinct.pluck(:project_type).sort
    @filter_years = unfiltered.pluck(Arel.sql("EXTRACT(YEAR FROM created_at)::int")).uniq.sort.reverse

    @projects = case @sort_col
    when "bid_due_at"
      base
        .joins("LEFT JOIN bid_submissions bs_sort ON bs_sort.project_id = projects.id AND bs_sort.discarded_at IS NULL AND bs_sort.bid_due_at IS NOT NULL")
        .select("projects.*, MIN(bs_sort.bid_due_at) AS earliest_due")
        .group("projects.id")
        .order(Arel.sql("MIN(bs_sort.bid_due_at) #{@sort_dir == 'asc' ? 'ASC NULLS LAST' : 'DESC NULLS FIRST'}"))
    when "bid_count"
      base
        .joins("LEFT JOIN bid_submissions bs_cnt ON bs_cnt.project_id = projects.id AND bs_cnt.discarded_at IS NULL")
        .select("projects.*, COUNT(bs_cnt.id) AS bid_count_val")
        .group("projects.id")
        .order(Arel.sql("COUNT(bs_cnt.id) #{@sort_dir}"))
    else
      base.order(Arel.sql("projects.#{@sort_col} #{@sort_dir} NULLS LAST"))
    end

    today = Date.current

    drafting_bids = BidSubmission.kept.where(status: :drafting)

    @bids_due_count = drafting_bids
      .select(:project_id).distinct.count

    @bids_due_soon_count = drafting_bids
      .where.not(bid_due_at: nil)
      .where(bid_due_at: today..(today + 2.days))
      .select(:project_id).distinct.count

    @bids_overdue_count = drafting_bids
      .where.not(bid_due_at: nil)
      .where(bid_due_at: ..today.yesterday)
      .select(:project_id).distinct.count
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
