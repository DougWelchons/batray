attributes :id, :name, :phone, :notes, :total_bid_submissions,
           :street, :city, :state, :zip_code

node :bid_submissions do |contractor|
  contractor.bid_submissions.map do |bid_submission|
    partial("api/v1/bid_submissions/_item", object: bid_submission, root: false)
  end
end
