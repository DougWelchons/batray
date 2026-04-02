class BidSubmissionsController < ApplicationController
  before_action :set_project
  before_action :set_bid_submission, only: [ :edit, :update, :discard ]

  def new
    @bid_submission = @project.bid_submissions.build(user: current_user)
    authorize @bid_submission
  end

  def create
    @bid_submission = @project.bid_submissions.build(bid_submission_params)
    @bid_submission.user ||= current_user
    authorize @bid_submission

    if @bid_submission.save
      respond_to do |format|
        format.html { redirect_to @project, notice: "Bid submission added." }
        format.turbo_stream
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @bid_submission
  end

  def update
    authorize @bid_submission

    if @bid_submission.update(bid_submission_params)
      respond_to do |format|
        format.html { redirect_to @project, notice: "Bid submission updated." }
        format.turbo_stream
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def discard
    authorize @bid_submission
    @bid_submission.discard
    redirect_to @project, notice: "Bid submission removed."
  end

  private

  def set_project
    @project = policy_scope(Project.kept).find(params[:project_id])
  end

  def set_bid_submission
    # @project is already scoped to company via policy_scope in set_project
    @bid_submission = @project.bid_submissions.kept.find(params[:id])
  end

  def bid_submission_params
    params.require(:bid_submission).permit(
      :contractor_id, :user_id, :status, :bid_submitted_at, :bid_due_at,
      :award_decision_at, :submitted_value, :awarded_value, :probability_percent,
      :included_fire_alarm, :included_low_voltage, :base_scope_description,
      :reason_lost, :notes
    )
  end
end
