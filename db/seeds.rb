# Seeds – idempotent, safe to re-run
# Simulates ~18 months of real usage

puts "Seeding database..."

# ============================================================
# Users
# ============================================================
admin = User.find_or_create_by!(email: "user@example.com") do |u|
  u.name     = "John Doe"
  u.role     = :admin
  u.password = "password"
  u.password_confirmation = "password"
end

estimator1 = User.find_or_create_by!(email: "sarah.chen@batray.com") do |u|
  u.name     = "Sarah Chen"
  u.role     = :estimator
  u.password = "password"
  u.password_confirmation = "password"
end

estimator2 = User.find_or_create_by!(email: "mike.torres@batray.com") do |u|
  u.name     = "Mike Torres"
  u.role     = :estimator
  u.password = "password"
  u.password_confirmation = "password"
end

viewer = User.find_or_create_by!(email: "ops@batray.com") do |u|
  u.name     = "Lisa Grant"
  u.role     = :viewer
  u.password = "password"
  u.password_confirmation = "password"
end

users = [ admin, estimator1, estimator2 ]
puts "  #{User.count} users"

# ============================================================
# Contractors
# ============================================================
gc_data = [
  { name: "Hensel Phelps",         contact_name: "Brad Kowalski",   email: "bkowalski@henselphelps.com",  phone: "720-555-0101" },
  { name: "Mortenson Construction", contact_name: "Amy Vance",      email: "avance@mortenson.com",        phone: "303-555-0142" },
  { name: "GE Johnson",             contact_name: "Derek Finch",    email: "dfinch@gejohnson.com",        phone: "719-555-0183" },
  { name: "Saunders Construction",  contact_name: "Renee Albright", email: "ralbright@saundersinc.com",   phone: "970-555-0217" },
  { name: "Weitz Company",          contact_name: "Tom Nguyen",     email: "tnguyen@weitz.com",           phone: "303-555-0268" },
  { name: "Kiewit Building Group",  contact_name: "Janet Hall",     email: "jhall@kiewit.com",            phone: "402-555-0329" },
  { name: "Turner Construction",    contact_name: "Paul Marsh",     email: "pmarsh@tcco.com",             phone: "212-555-0344" },
  { name: "DPR Construction",       contact_name: "Carla Diaz",     email: "cdiaz@dprinc.com",            phone: "480-555-0391" },
]

contractors = gc_data.map do |attrs|
  Contractor.find_or_create_by!(name: attrs[:name]) do |c|
    c.contact_name = attrs[:contact_name]
    c.email        = attrs[:email]
    c.phone        = attrs[:phone]
  end
end

puts "  #{Contractor.count} contractors"

# ============================================================
# Helper lambdas
# ============================================================
project_types = [ "Office", "Medical", "Industrial", "Retail", "Education", "Hospitality", "Data Center", "Multifamily" ]
locations     = [
  "Denver, CO", "Colorado Springs, CO", "Boulder, CO", "Fort Collins, CO",
  "Aurora, CO", "Pueblo, CO", "Loveland, CO", "Greeley, CO", "Lakewood, CO"
]

rand_gc_subset = ->(min: 2, max: 4) { contractors.sample(rand(min..max)) }
rand_value     = ->(low, high) { (rand * (high - low) + low).round(-3) }
rand_date      = ->(months_ago_max, months_ago_min = 0) {
  days = rand((months_ago_min * 30)..(months_ago_max * 30))
  Date.today - days
}

# ============================================================
# Projects – historical (12-18 months ago, fully resolved)
# ============================================================
historical_projects = [
  { name: "Panorama Medical Campus – Phase 1",  type: "Medical",     location: "Denver, CO" },
  { name: "Flatiron Tech Hub",                  type: "Office",      location: "Boulder, CO" },
  { name: "Alpine Distribution Center",         type: "Industrial",  location: "Aurora, CO" },
  { name: "Centennial Retail Plaza",            type: "Retail",      location: "Greenwood Village, CO" },
  { name: "Mesa Ridge Elementary School",       type: "Education",   location: "Colorado Springs, CO" },
  { name: "Summit View Hotel & Conference",     type: "Hospitality", location: "Denver, CO" },
  { name: "Ridgeline Data Center – Building A", type: "Data Center", location: "Loveland, CO" },
  { name: "Northgate Apartment Complex",        type: "Multifamily", location: "Fort Collins, CO" },
  { name: "Broadmoor Office Park",              type: "Office",      location: "Colorado Springs, CO" },
  { name: "High Plains Fulfillment Hub",        type: "Industrial",  location: "Greeley, CO" },
]

historical_projects.each do |proj_attrs|
  next if Project.exists?(name: proj_attrs[:name])

  bid_date      = rand_date.call(18, 13)
  decision_date = bid_date + rand(45..90)
  gc_list       = rand_gc_subset.call(min: 3, max: 5)
  won_gc        = gc_list.sample

  project = Project.create!(
    name:                 proj_attrs[:name],
    location:             proj_attrs[:location],
    project_type:         proj_attrs[:type],
    estimated_start_date: bid_date + rand(60..120)
  )

  gc_list.each do |gc|
    submitted_val = rand_value.call(280_000, 2_400_000)
    awarded_val   = gc == won_gc ? (submitted_val * rand(0.92..1.05)).round(-3) : nil
    status        = gc == won_gc ? :awarded : :lost

    project.bid_submissions.create!(
      contractor:          gc,
      user:                users.sample,
      status:              status,
      bid_submitted_at:    bid_date,
      bid_due_at:          bid_date - rand(3..7),
      award_decision_at:   decision_date,
      submitted_value:     submitted_val,
      awarded_value:       awarded_val,
      probability_percent: gc == won_gc ? rand(60..85) : rand(20..50),
      included_fire_alarm: [ true, false ].sample,
      included_low_voltage: [ true, false ].sample,
      base_scope_description: "Full electrical scope including service entrance, distribution, lighting, and devices."
    )
  end
end

# ============================================================
# Projects – mid-cycle (5-12 months ago, mixed outcomes)
# ============================================================
mid_projects = [
  { name: "Lodo Creative Office – 7th & Blake",  type: "Office",      location: "Denver, CO" },
  { name: "Peak Performance Sports Complex",      type: "Education",   location: "Lakewood, CO" },
  { name: "Spruce Mountain Brewery Expansion",    type: "Industrial",  location: "Pueblo, CO" },
  { name: "Catalyst Biotech Laboratory",          type: "Medical",     location: "Boulder, CO" },
  { name: "Prairie Wind Logistics Park",          type: "Industrial",  location: "Aurora, CO" },
  { name: "Timberline Mixed-Use Tower",           type: "Multifamily", location: "Denver, CO" },
  { name: "Mesa County Justice Center",           type: "Office",      location: "Grand Junction, CO" },
  { name: "Vail Valley Medical Clinic",           type: "Medical",     location: "Vail, CO" },
]

mid_projects.each do |proj_attrs|
  next if Project.exists?(name: proj_attrs[:name])

  bid_date = rand_date.call(12, 5)
  gc_list  = rand_gc_subset.call(min: 2, max: 4)

  # Some awarded, some lost, some still pending decision
  outcomes = [ :awarded, :lost, :lost, :withdrawn ].first(gc_list.size)
  outcomes[0] = :awarded if rand < 0.6  # 60% win rate on these

  project = Project.create!(
    name:                 proj_attrs[:name],
    location:             proj_attrs[:location],
    project_type:         proj_attrs[:type],
    estimated_start_date: bid_date + rand(60..180)
  )

  gc_list.each_with_index do |gc, i|
    status        = outcomes[i] || :lost
    submitted_val = rand_value.call(180_000, 1_800_000)
    awarded_val   = status == :awarded ? (submitted_val * rand(0.94..1.03)).round(-3) : nil
    decision_date = status.in?([ :awarded, :lost ]) ? bid_date + rand(30..75) : nil

    project.bid_submissions.create!(
      contractor:           gc,
      user:                 users.sample,
      status:               status,
      bid_submitted_at:     bid_date,
      bid_due_at:           bid_date - rand(2..5),
      award_decision_at:    decision_date,
      submitted_value:      submitted_val,
      awarded_value:        awarded_val,
      probability_percent:  status == :awarded ? rand(55..80) : rand(15..45),
      included_fire_alarm:  [ true, false ].sample,
      included_low_voltage: [ true, false ].sample,
      reason_lost:          status == :lost ? [ "Price – came in high", "Relationship with incumbent EC", "Scope differences", "Budget cut" ].sample : nil,
      base_scope_description: "Electrical scope per drawings and specs."
    )
  end
end

# ============================================================
# Projects – recent (0-5 months ago, active pipeline)
# ============================================================
recent_projects = [
  { name: "Centerra Medical Office Building",   type: "Medical",     location: "Loveland, CO" },
  { name: "Union Station Hotel Renovation",     type: "Hospitality", location: "Denver, CO" },
  { name: "Front Range Community College – Bldg C", type: "Education", location: "Fort Collins, CO" },
  { name: "Arapahoe Commerce Center",           type: "Industrial",  location: "Centennial, CO" },
  { name: "Highlands Ranch Data Center – Pod 2", type: "Data Center", location: "Highlands Ranch, CO" },
  { name: "The Confluence – Residential Tower", type: "Multifamily", location: "Denver, CO" },
]

recent_projects.each do |proj_attrs|
  next if Project.exists?(name: proj_attrs[:name])

  bid_date = rand_date.call(5, 0)
  gc_list  = rand_gc_subset.call(min: 2, max: 4)

  project = Project.create!(
    name:                 proj_attrs[:name],
    location:             proj_attrs[:location],
    project_type:         proj_attrs[:type],
    estimated_start_date: Date.today + rand(60..240)
  )

  gc_list.each do |gc|
    submitted_val = rand_value.call(150_000, 3_200_000)
    # Recent bids are submitted or still drafting
    status = bid_date < Date.today - 7 ? :submitted : :drafting

    project.bid_submissions.create!(
      contractor:           gc,
      user:                 users.sample,
      status:               status,
      bid_submitted_at:     status == :submitted ? bid_date : nil,
      bid_due_at:           bid_date + rand(3..10),
      submitted_value:      status == :submitted ? submitted_val : nil,
      probability_percent:  rand(40..70),
      included_fire_alarm:  [ true, false ].sample,
      included_low_voltage: [ true, false ].sample,
      base_scope_description: "Electrical – full scope per IFC drawings."
    )
  end
end

# ============================================================
# One rebid to demonstrate the feature
# ============================================================
original = Project.find_by(name: "Alpine Distribution Center")
if original && !Project.exists?(name: "Alpine Distribution Center – Rebid")
  rebid = original.duplicate_for_rebid
  rebid.name = "Alpine Distribution Center – Rebid"
  rebid.estimated_start_date = Date.today + 90
  rebid.save!

  original.bid_submissions.kept.each do |bid|
    rebid.bid_submissions.create!(
      contractor:           bid.contractor,
      user:                 bid.user,
      status:               :drafting,
      bid_due_at:           Date.today + 14,
      probability_percent:  bid.probability_percent,
      included_fire_alarm:  bid.included_fire_alarm,
      included_low_voltage: bid.included_low_voltage,
      base_scope_description: bid.base_scope_description
    )
  end
end

puts "  #{Project.count} projects"
puts "  #{BidSubmission.count} bid submissions"
puts ""
puts "Done! Login: user@example.com / password"
