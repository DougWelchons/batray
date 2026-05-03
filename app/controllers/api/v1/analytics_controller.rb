class Api::V1::AnalyticsController < Api::V1::BaseController
  def dashboard
    bid_submissions = BidSubmission
      .joins(:project)
      .where(projects: { company_id: @company.id })

    year_start = Date.current.beginning_of_year

    qualifying_bids = bid_submissions.kept
      .where(status: %w[submitted awarded lost])
      .where("bid_submitted_at >= ?", year_start)

    qualifying_project_ids = qualifying_bids.select(:project_id).distinct
    total_bids_ytd = qualifying_project_ids.count

    total_awarded_ytd = bid_submissions.kept
      .where(status: :awarded)
      .where("award_decision_at >= ?", year_start)
      .sum(:awarded_value)

    awarded_project_ids = bid_submissions.kept
      .where(status: :awarded)
      .where("award_decision_at >= ?", year_start)
      .select(:project_id)
      .distinct
    awarded_project_count = awarded_project_ids.count

    win_rate = total_bids_ytd > 0 ? (awarded_project_count.to_f / total_bids_ytd * 100).round(1) : nil

    numerator = total_awarded_ytd.to_f
    qualifying_pid_list = qualifying_project_ids.map(&:project_id)
    dollar_win_rate = nil

    if qualifying_pid_list.any?
      awarded_pid_list = awarded_project_ids.map(&:project_id)
      non_awarded_pids = qualifying_pid_list - awarded_pid_list

      denominator = 0.0

      if awarded_pid_list.any?
        denominator += bid_submissions.kept
          .where(status: :awarded)
          .where("award_decision_at >= ?", year_start)
          .where(project_id: awarded_pid_list)
          .sum(:awarded_value)
      end

      if non_awarded_pids.any?
        avg_per_project = bid_submissions.kept
          .where(status: %w[submitted lost])
          .where(project_id: non_awarded_pids)
          .group(:project_id)
          .average(:submitted_value)
        denominator += avg_per_project.values.sum
      end

      dollar_win_rate = denominator > 0 ? (numerator / denominator * 100).round(1) : nil
    end

    @stats = {
      total_bids_ytd:    total_bids_ytd,
      total_awarded_ytd: total_awarded_ytd.to_f,
      win_rate:          win_rate,
      dollar_win_rate:   dollar_win_rate
    }

    @bids_per_month = bid_submissions
      .where(status: %w[submitted awarded lost])
      .where.not(bid_submitted_at: nil)
      .group(Arel.sql("DATE_TRUNC('month', bid_submitted_at)"))
      .order(Arel.sql("DATE_TRUNC('month', bid_submitted_at)"))
      .count
      .map { |month, count| { month: month.strftime("%Y-%m"), count: count } }

    @awarded_revenue_by_month = bid_submissions
      .where(status: "awarded")
      .where.not(award_decision_at: nil)
      .group(Arel.sql("DATE_TRUNC('month', award_decision_at)"))
      .order(Arel.sql("DATE_TRUNC('month', award_decision_at)"))
      .sum(:awarded_value)
      .map { |month, total| { month: month.strftime("%Y-%m"), total: total.to_f } }

    @contractor_data = bid_submissions
      .joins(:contractor)
      .where(status: %w[submitted awarded lost])
      .group("contractors.id", "contractors.name")
      .order("contractors.name")
      .select(
        "contractors.id",
        "contractors.name",
        "COUNT(*) AS total_bids",
        "COUNT(*) FILTER (WHERE bid_submissions.status = 'awarded') AS total_wins",
        "SUM(bid_submissions.submitted_value) AS bid_value",
        "COALESCE(SUM(bid_submissions.awarded_value) FILTER (WHERE bid_submissions.status = 'awarded'), 0) AS win_value",
        "MAX(bid_submissions.bid_submitted_at) AS last_bid_at",
        "MAX(bid_submissions.award_decision_at) FILTER (WHERE bid_submissions.status = 'awarded') AS last_awarded_at"
      )
      .map do |row|
        total_bids = row.total_bids.to_i
        total_wins = row.total_wins.to_i
        bid_value  = row.bid_value.to_f
        win_value  = row.win_value.to_f
        {
          id:             row.id,
          name:           row.name,
          total_bids:     total_bids,
          total_wins:     total_wins,
          win_pct:        total_bids > 0 ? (total_wins.to_f / total_bids * 100).round(1) : nil,
          bid_value:      bid_value,
          win_value:      win_value,
          value_pct:      bid_value > 0 ? (win_value / bid_value * 100).round(1) : nil,
          last_bid_at:    row.last_bid_at,
          last_awarded_at: row.last_awarded_at
        }
      end
  end
end
