class DashboardController < ApplicationController
  def index
    year_start = Date.current.beginning_of_year

    # Projects with at least one submitted/awarded/lost bid submitted this year
    qualifying_project_ids = BidSubmission.kept
      .where(status: [ :submitted, :awarded, :lost ])
      .where("bid_submitted_at >= ?", year_start)
      .select(:project_id)
      .distinct

    # Total Bids YTD: count of distinct qualifying projects (not individual bids)
    @total_bids_ytd = qualifying_project_ids.count

    # Awarded Revenue YTD: sum of awarded_value where award was decided this year
    @total_awarded_ytd = BidSubmission.kept
      .where(status: :awarded)
      .where("award_decision_at >= ?", year_start)
      .sum(:awarded_value)

    # Win Rate YTD (project-level): awarded projects / qualifying projects
    awarded_project_ids = BidSubmission.kept
      .where(status: :awarded)
      .where("award_decision_at >= ?", year_start)
      .select(:project_id)
      .distinct
    awarded_project_count = awarded_project_ids.count
    qualifying_count = @total_bids_ytd
    @win_rate = qualifying_count > 0 ? (awarded_project_count.to_f / qualifying_count * 100).round(1) : nil

    # Dollar Win Rate YTD:
    # Numerator: SUM of awarded_value for projects awarded this year
    # Denominator: for each qualifying project, use awarded_value if won,
    #              else average submitted_value of its submitted/lost bids
    numerator = BidSubmission.kept
      .where(status: :awarded)
      .where("award_decision_at >= ?", year_start)
      .sum(:awarded_value)

    # Build per-project representative value using a subquery
    # For awarded projects: their awarded_value
    # For non-awarded qualifying projects: average submitted_value of submitted/lost bids
    qualifying_project_id_list = qualifying_project_ids.map(&:project_id)
    if qualifying_project_id_list.any?
      awarded_pid_list = awarded_project_ids.map(&:project_id)
      non_awarded_pids = qualifying_project_id_list - awarded_pid_list

      denominator = 0.0

      if awarded_pid_list.any?
        denominator += BidSubmission.kept
          .where(status: :awarded)
          .where("award_decision_at >= ?", year_start)
          .where(project_id: awarded_pid_list)
          .sum(:awarded_value)
      end

      if non_awarded_pids.any?
        # Average submitted_value per non-awarded project, then sum those averages
        avg_per_project = BidSubmission.kept
          .where(status: [ :submitted, :lost ])
          .where(project_id: non_awarded_pids)
          .group(:project_id)
          .average(:submitted_value)
        denominator += avg_per_project.values.sum
      end

      @dollar_win_rate = denominator > 0 ? (numerator.to_f / denominator * 100).round(1) : nil
    else
      @dollar_win_rate = nil
    end

    @monthly_bid_volume = BidSubmission.kept
      .where.not(bid_submitted_at: nil)
      .group_by_month(:bid_submitted_at, last: 12)
      .count

    @monthly_awarded_revenue = BidSubmission.kept
      .where(status: :awarded)
      .where.not(award_decision_at: nil)
      .group_by_month(:award_decision_at, last: 12)
      .sum(:awarded_value)

    # GC win rate: bid-level (all time), excludes withdrawn and declined
    @win_rate_by_gc = BidSubmission.kept
      .joins(:contractor)
      .where(status: [ :submitted, :awarded, :lost ])
      .group("contractors.name")
      .select(
        "contractors.name as gc_name",
        "COUNT(*) as total_bids",
        "SUM(CASE WHEN bid_submissions.status = #{BidSubmission.statuses[:awarded]} THEN 1 ELSE 0 END) as awarded_count"
      )
  end
end
