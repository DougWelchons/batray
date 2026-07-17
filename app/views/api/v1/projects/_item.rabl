attributes :id, :name, :street, :city, :state, :zip_code, :estimated_start_date,
           :rebid_of_id, :earliest_bid_due_at, :bid_count, :project_status, :project_due_status,
           :estimators_ids

node :bid_submissions do |project|
  project.bid_submissions.map do |bid_submission|
    partial("api/v1/bid_submissions/_item", object: bid_submission, root: false)
  end
end

node :classification_ids do |project|
  project.classifications.map(&:id)
end
