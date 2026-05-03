class Api::V1::AnalyticsController < Api::V1::BaseController
  def dashboard
    bid_submissions = BidSubmission
      .joins(:project)
      .where(projects: { company_id: @company.id })

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
