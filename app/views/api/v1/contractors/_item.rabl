attributes :id, :name, :contact_name, :email, :phone, :notes, :total_bid_submissions

node :bid_submissions do |contractor|
  contractor.bid_submissions.map do |bid_submission|
    partial('api/v1/bid_submissions/_item', object: bid_submission, root: false)
  end
end

node :contacts do |contractor|
  contractor.contacts.map do |contact|
    partial('api/v1/contacts/_item', object: contact, root: false)
  end
end
