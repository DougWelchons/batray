class DashboardController < ApplicationController
  def index
    @bids_ytd = BidSubmission.kept.where("created_at >= ?", Date.current.beginning_of_year)
    @total_bids_ytd = @bids_ytd.for_metrics.count
    @total_awarded_ytd = @bids_ytd.won.sum(:awarded_value)
    @win_rate = BidSubmission.win_rate
    @dollar_win_rate = BidSubmission.dollar_win_rate

    @monthly_bid_volume = BidSubmission.kept
      .where.not(bid_submitted_at: nil)
      .group_by_month(:bid_submitted_at, last: 12)
      .count

    @monthly_awarded_revenue = BidSubmission.kept
      .where(status: :awarded)
      .where.not(award_decision_at: nil)
      .group_by_month(:award_decision_at, last: 12)
      .sum(:awarded_value)

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
