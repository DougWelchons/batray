# Seeds – idempotent, safe to re-run
# Requires: faker, factory_bot_rails gems
# Covers: ~15 GCs, 6 users, 20 drafting, ~89 this year, ~75 last year, ~75 two years ago
# Rebid chains, correct win/loss ratios, San Diego area locations

require "faker"

puts "Seeding database..."
puts "  Clearing existing data..."

# Clear in dependency order so we can re-run safely
BidSubmission.unscoped.delete_all
Project.unscoped.delete_all
Contractor.unscoped.delete_all
User.unscoped.delete_all

Faker::UniqueGenerator.clear

# ============================================================
# Constants / lookup data
# ============================================================

PROJECT_TYPES = %w[Office Medical Industrial Retail Education Hospitality Data\ Center Multifamily].freeze

SD_LOCATIONS = [
  "San Diego, CA",
  "San Diego, CA",
  "San Diego, CA",
  "Chula Vista, CA",
  "El Cajon, CA",
  "Escondido, CA",
  "Santee, CA",
  "La Mesa, CA",
  "National City, CA",
  "Poway, CA",
  "Oceanside, CA",
  "Carlsbad, CA",
  "Vista, CA",
  "San Marcos, CA",
  "Encinitas, CA",
  "Coronado, CA",
  "Lemon Grove, CA",
  "Spring Valley, CA",
  "Lakeside, CA",
  "Ramona, CA",
  "Los Angeles, CA",
  "Riverside, CA",
  "Temecula, CA",
].freeze

SCOPE_DESCRIPTIONS = [
  "Full electrical scope including service entrance, distribution, lighting, and devices.",
  "Electrical scope per IFC drawings and project specifications.",
  "Complete power and lighting systems including emergency/egress.",
  "Electrical rough and finish per drawings; fire alarm by others.",
  "Full electrical including low voltage rough-in, power, lighting controls.",
  "Service entrance, distribution, branch circuits, lighting, fire alarm, and low voltage.",
  "Electrical per Division 26; excludes specialty systems.",
  "Complete electrical systems including switchgear, panels, lighting, and devices.",
].freeze

REASONS_LOST = [
  "Price – came in high",
  "Price – came in high",
  "Relationship with incumbent EC",
  "Scope differences",
  "Budget cut",
  "GC self-performed",
  "Owner canceled project",
  "Missed bid deadline",
  "Bonding requirement",
  "Out-of-area GC preference",
].freeze

# ============================================================
# Users
# ============================================================

puts "  Creating users..."

admin = User.create!(
  name: "Doug Wilson",
  email: "user@example.com",
  role: :admin,
  password: "password",
  password_confirmation: "password"
)

estimators = [
  { name: "Sarah Chen",    email: "sarah.chen@batray.com",    role: :estimator },
  { name: "Mike Torres",   email: "mike.torres@batray.com",   role: :estimator },
  { name: "Jen Nakamura",  email: "jen.nakamura@batray.com",  role: :estimator },
  { name: "Carlos Reyes",  email: "carlos.reyes@batray.com",  role: :estimator },
  { name: "Lisa Grant",    email: "lisa.grant@batray.com",    role: :viewer    },
].map do |attrs|
  User.create!(
    name: attrs[:name],
    email: attrs[:email],
    role: attrs[:role],
    password: "password",
    password_confirmation: "password"
  )
end

# Users who appear on bids (estimators only)
bid_users = [admin] + estimators.select { |u| u.estimator? }

puts "  #{User.count} users"

# ============================================================
# Contractors (GCs) – 15 San Diego / Southern CA firms
# ============================================================

puts "  Creating contractors..."

gc_data = [
  { name: "McCarthy Building Companies",  contact_name: "Brian Holloway",   email: "bholloway@mccarthy.com",         phone: "619-555-0101" },
  { name: "Rudolph and Sletten",          contact_name: "Diane Park",       email: "dpark@rsconstruction.com",       phone: "619-555-0118" },
  { name: "Turner Construction",          contact_name: "Paul Marsh",       email: "pmarsh@tcco.com",                phone: "619-555-0134" },
  { name: "DPR Construction",             contact_name: "Carla Diaz",       email: "cdiaz@dprinc.com",               phone: "619-555-0152" },
  { name: "Hensel Phelps",               contact_name: "Brad Kowalski",    email: "bkowalski@henselphelps.com",     phone: "858-555-0167" },
  { name: "Kitchell Contractors",         contact_name: "Greg Salazar",     email: "gsalazar@kitchell.com",          phone: "619-555-0183" },
  { name: "Clark Construction Group",     contact_name: "Tamara Wells",     email: "twells@clarkconstruction.com",   phone: "858-555-0199" },
  { name: "Swinerton Builders",           contact_name: "Nate Fujimoto",    email: "nfujimoto@swinerton.com",        phone: "619-555-0214" },
  { name: "Balfour Beatty Construction",  contact_name: "Renee Albright",   email: "ralbright@balfourbeatty.com",    phone: "858-555-0230" },
  { name: "Sundt Construction",           contact_name: "Victor Olsen",     email: "volsen@sundt.com",               phone: "619-555-0247" },
  { name: "Webcor Builders",              contact_name: "Amy Vance",        email: "avance@webcor.com",              phone: "858-555-0261" },
  { name: "Skanska USA Building",         contact_name: "Derek Finch",      email: "dfinch@skanska.com",             phone: "619-555-0278" },
  { name: "Gilbane Building Company",     contact_name: "Monica Stein",     email: "mstein@gilbaneco.com",           phone: "619-555-0293" },
  { name: "Soltek Pacific Construction",  contact_name: "James Okafor",     email: "jokafor@soltekpacific.com",      phone: "619-555-0309" },
  { name: "Lusardi Construction",         contact_name: "Rachel Torrez",    email: "rtorrez@lusardiconstruction.com", phone: "760-555-0324" },
].freeze

contractors = gc_data.map do |attrs|
  Contractor.create!(
    name:         attrs[:name],
    contact_name: attrs[:contact_name],
    email:        attrs[:email],
    phone:        attrs[:phone]
  )
end

puts "  #{Contractor.count} contractors"

# ============================================================
# Project name generation – realistic SD-area construction
# ============================================================

SD_PROJECT_PREFIXES = [
  "Balboa", "Gaslamp", "Cabrillo", "Coronado", "Torrey Pines", "Miramar",
  "Kearny Mesa", "Mission Valley", "Otay Ranch", "Chula Vista", "Rancho Bernardo",
  "Sorrento Valley", "Carmel Valley", "Scripps Ranch", "La Jolla", "Point Loma",
  "Eastlake", "Bonita", "Escondido", "El Cajon", "Carlsbad", "Oceanside",
  "San Marcos", "Vista", "Poway", "Santee", "Alpine", "Spring Valley",
  "National City", "Lemon Grove", "Encinitas", "Solana Beach", "Del Mar",
  "Temecula", "Murrieta", "Riverside", "Burbank", "Glendale"
].freeze

SD_PROJECT_SUFFIXES = {
  "Office"       => ["Office Park", "Corporate Center", "Tech Hub", "Business Center", "Professional Plaza", "Office Building", "Innovation Campus"],
  "Medical"      => ["Medical Center", "Medical Office Building", "Health Pavilion", "Surgery Center", "Medical Campus", "Outpatient Clinic", "Medical Plaza"],
  "Industrial"   => ["Distribution Center", "Logistics Hub", "Warehouse Facility", "Manufacturing Plant", "Industrial Park", "Fulfillment Center", "Cold Storage Facility"],
  "Retail"       => ["Retail Center", "Shopping Plaza", "Lifestyle Center", "Retail Village", "Mixed-Use Retail", "Strip Mall Renovation", "Big Box Anchor"],
  "Education"    => ["Elementary School", "Middle School", "High School Modernization", "Community College Building", "University Research Hall", "STEM Center", "Library & Learning Commons"],
  "Hospitality"  => ["Hotel & Conference Center", "Extended Stay Hotel", "Boutique Hotel Renovation", "Resort Expansion", "Marriott Renovation", "Hotel Tower"],
  "Data Center"  => ["Data Center – Phase 1", "Data Center – Phase 2", "Colocation Facility", "Network Operations Center", "Edge Data Center", "Server Farm Build-Out"],
  "Multifamily"  => ["Apartment Complex", "Mixed-Use Residential Tower", "Senior Living Community", "Affordable Housing", "Market-Rate Apartments", "Townhome Development", "Student Housing"],
}.freeze

used_project_names = Set.new

def generate_project_name(type, used_names)
  prefixes = SD_PROJECT_PREFIXES.dup.shuffle
  suffixes = SD_PROJECT_SUFFIXES[type] || ["Building"]
  loop do
    name = "#{prefixes.sample} #{suffixes.sample}"
    unless used_names.include?(name)
      used_names.add(name)
      return name
    end
  end
end

# ============================================================
# Core bid creation helper
# ============================================================

def rand_value_cluster(base_value, spread: 0.10)
  variation = 1.0 + (rand * 2 * spread) - spread
  (base_value * variation).round(-3)
end

def create_bids_for_project(project:, gc_list:, bid_submitted_at:, bid_due_at:, outcomes:, bid_users:)
  base_value = rand(150_000..4_500_000).round(-3)

  # Determine if any bid is awarded
  awarded_gc = gc_list[outcomes.index(:awarded)] if outcomes.include?(:awarded)

  gc_list.each_with_index do |gc, i|
    status = outcomes[i]
    submitted_value = rand_value_cluster(base_value)

    awarded_value    = nil
    award_decision_at = nil

    if status == :awarded
      awarded_value     = (submitted_value * rand(0.93..1.06)).round(-3)
      award_decision_at = bid_submitted_at + rand(30..90)
    elsif status == :lost
      award_decision_at = bid_submitted_at + rand(30..90)
    end

    # Bid due date: same or within 2 days of each other
    this_bid_due = bid_due_at + rand(-2..2)

    project.bid_submissions.create!(
      contractor:            gc,
      user:                  bid_users.sample,
      status:                status,
      bid_submitted_at:      bid_submitted_at,
      bid_due_at:            this_bid_due,
      award_decision_at:     award_decision_at,
      submitted_value:       submitted_value,
      awarded_value:         awarded_value,
      probability_percent:   status == :awarded ? rand(55..85) : (status == :lost ? rand(10..45) : rand(35..65)),
      included_fire_alarm:   [true, false].sample,
      included_low_voltage:  [true, false].sample,
      reason_lost:           status == :lost ? REASONS_LOST.sample : nil,
      base_scope_description: SCOPE_DESCRIPTIONS.sample
    )
  end
end

# ============================================================
# Helper: assign outcomes for a batch of projects
#
# won_pct:      fraction that should have one awarded bid
# lost_pct:     fraction where all resolved bids are lost
# pending_pct:  remainder – all submitted/no decision yet
# small chance of withdrawn/declined mixed in
# ============================================================

def assign_project_outcomes(gc_list, mode:)
  # mode: :awarded, :lost, :pending
  size = gc_list.size

  case mode
  when :awarded
    # One winner, rest lost (occasional withdrawn/declined)
    outcomes = Array.new(size, :lost)
    outcomes[0] = :awarded
    # Sprinkle 0-1 withdrawn or declined among the losers
    if size > 2 && rand < 0.25
      idx = (1...size).to_a.sample
      outcomes[idx] = [:withdrawn, :declined].sample
    end

  when :lost
    # All lost, occasional withdrawn/declined
    outcomes = Array.new(size, :lost)
    (1...size).each do |i|
      outcomes[i] = [:withdrawn, :declined].sample if rand < 0.12
    end

  when :pending
    # All submitted, occasional lost/withdrawn among them
    outcomes = Array.new(size, :submitted)
    (1...size).each do |i|
      if rand < 0.15
        outcomes[i] = [:lost, :withdrawn, :declined].sample
      end
    end
  end

  outcomes.shuffle
end

# ============================================================
# Generate a batch of fully-resolved projects
#
# count:      number of projects to create
# year_offset: 0 = this year, 1 = last year, 2 = two years ago
# won_pct, lost_pct, pending_pct: ratios (should sum to ~1.0)
# ============================================================

def create_project_batch(count:, year_offset:, won_pct:, lost_pct:, pending_pct:,
                         contractors:, bid_users:, used_names:)
  year_start = Date.new(Date.today.year - year_offset, 1, 1)
  year_end   = year_offset.zero? ? Date.today - 1 : Date.new(Date.today.year - year_offset, 12, 31)

  projects = []

  count.times do |i|
    # Assign outcome mode based on ratios
    r = rand
    mode = if r < won_pct
      :awarded
    elsif r < won_pct + lost_pct
      :lost
    else
      :pending
    end

    type     = PROJECT_TYPES.sample
    location = SD_LOCATIONS.sample
    name     = generate_project_name(type, used_names)

    bid_submitted_at = rand(year_start..year_end)
    bid_due_at       = bid_submitted_at - rand(3..10)
    start_date       = bid_submitted_at + rand(60..240)

    project = Project.create!(
      name:                 name,
      location:             location,
      project_type:         type,
      estimated_start_date: start_date
    )

    gc_count = rand(1..6)
    gc_list  = contractors.sample(gc_count)

    outcomes = assign_project_outcomes(gc_list, mode: mode)

    # For pending projects in past years, mark as lost (can't still be pending 2 years later)
    if year_offset >= 1 && mode == :pending
      outcomes = outcomes.map { |o| o == :submitted ? :lost : o }
    end

    create_bids_for_project(
      project:          project,
      gc_list:          gc_list,
      bid_submitted_at: bid_submitted_at,
      bid_due_at:       bid_due_at,
      outcomes:         outcomes,
      bid_users:        bid_users
    )

    projects << project
  end

  projects
end

# ============================================================
# THIS YEAR – ~89 projects
# 20% awarded, 55% lost, 25% pending
# ============================================================

puts "  Creating this year's projects (~89)..."

this_year_projects = create_project_batch(
  count:       89,
  year_offset: 0,
  won_pct:     0.20,
  lost_pct:    0.55,
  pending_pct: 0.25,
  contractors: contractors,
  bid_users:   bid_users,
  used_names:  used_project_names
)

puts "    #{this_year_projects.size} projects created"

# ============================================================
# LAST YEAR – ~75 projects
# 25% awarded, 75% lost (a few declined/withdrawn mixed in)
# pending_pct: 0 – all resolved
# ============================================================

puts "  Creating last year's projects (~75)..."

last_year_projects = create_project_batch(
  count:       75,
  year_offset: 1,
  won_pct:     0.25,
  lost_pct:    0.75,
  pending_pct: 0.00,
  contractors: contractors,
  bid_users:   bid_users,
  used_names:  used_project_names
)

puts "    #{last_year_projects.size} projects created"

# ============================================================
# TWO YEARS AGO – ~75 projects
# 25% awarded, 75% lost (same ratios)
# ============================================================

puts "  Creating two-years-ago projects (~75)..."

two_years_ago_projects = create_project_batch(
  count:       75,
  year_offset: 2,
  won_pct:     0.25,
  lost_pct:    0.75,
  pending_pct: 0.00,
  contractors: contractors,
  bid_users:   bid_users,
  used_names:  used_project_names
)

puts "    #{two_years_ago_projects.size} projects created"

# ============================================================
# DRAFTING PROJECTS – 20 projects currently in pipeline
#
# Due date urgency:
#   4 projects: due within next 2 days
#   2 projects: overdue by a few days
#   14 projects: due in the future (1–6 weeks out)
#
# Most bids still in :drafting; some projects have no bids yet.
# ============================================================

puts "  Creating 20 drafting projects..."

due_date_configs = [
  # [date_offset_days, label]
  *Array.new(4)  { [rand(0..2),   :warning] },   # due within 2 days
  *Array.new(2)  { [-rand(2..5),  :overdue] },    # overdue
  *Array.new(14) { [rand(5..42),  :future]  },    # future
].shuffle

due_date_configs.each_with_index do |config, i|
  days_offset = config[0]
  bid_due_at  = Date.today + days_offset

  type     = PROJECT_TYPES.sample
  location = SD_LOCATIONS.sample
  name     = generate_project_name(type, used_project_names)

  project = Project.create!(
    name:                 name,
    location:             location,
    project_type:         type,
    estimated_start_date: Date.today + rand(60..300)
  )

  gc_count = rand(1..6)
  gc_list  = contractors.sample(gc_count)

  # Decide how many bids this project has (some have none yet)
  has_bids = i > 2  # first 3 projects have no bids yet

  next unless has_bids

  base_value = rand(150_000..4_500_000).round(-3)

  gc_list.each do |gc|
    # Mostly drafting; occasional submitted if it's a slightly older draft
    status = rand < 0.85 ? :drafting : :submitted
    submitted_value  = status == :submitted ? rand_value_cluster(base_value) : nil
    bid_submitted_at = status == :submitted ? bid_due_at - rand(1..5) : nil

    project.bid_submissions.create!(
      contractor:            gc,
      user:                  bid_users.sample,
      status:                status,
      bid_due_at:            bid_due_at + rand(-2..2),
      bid_submitted_at:      bid_submitted_at,
      submitted_value:       submitted_value,
      probability_percent:   rand(40..70),
      included_fire_alarm:   [true, false].sample,
      included_low_voltage:  [true, false].sample,
      base_scope_description: SCOPE_DESCRIPTIONS.sample
    )
  end
end

puts "    #{20} drafting projects created"

# ============================================================
# REBIDS – ~5% of all projects
#
# Rules:
#   - Source project must be lost
#   - Rebid resets status to drafting, clears dates/values
#   - At least one 3-deep chain (rebid of a rebid)
#   - Rebid projects are included in this year's pipeline
# ============================================================

puts "  Creating rebid projects..."

all_projects = Project.all.to_a
total_projects = all_projects.size
rebid_count = (total_projects * 0.05).round

# Candidates: projects that have at least one lost bid, no awarded bids, and are not already rebids
already_rebound_ids = Project.where.not(rebid_of_id: nil).pluck(:rebid_of_id).compact
awarded_project_ids = BidSubmission.where(status: :awarded).pluck(:project_id).uniq
lost_project_ids    = BidSubmission.where(status: :lost).pluck(:project_id).uniq

rebid_candidates = Project
  .where(id: lost_project_ids)
  .where.not(id: awarded_project_ids)
  .where.not(id: already_rebound_ids)
  .where(rebid_of_id: nil)
  .to_a
  .sample(rebid_count + 5)
  .first(rebid_count)

created_rebids = []

rebid_candidates.each_with_index do |original, i|
  type     = original.project_type
  location = original.location
  name     = "#{original.name} – Rebid"

  next if used_project_names.include?(name)
  used_project_names.add(name)

  rebid = Project.create!(
    name:                 name,
    location:             location,
    project_type:         type,
    estimated_start_date: Date.today + rand(45..180),
    rebid_of_id:          original.id
  )

  # Rebid gets fresh drafting bids mirroring original GCs
  gc_list    = original.bid_submissions.map(&:contractor).uniq
  base_value = rand(150_000..4_500_000).round(-3)
  bid_due_at = Date.today + rand(7..30)

  gc_list.each do |gc|
    rebid.bid_submissions.create!(
      contractor:            gc,
      user:                  bid_users.sample,
      status:                :drafting,
      bid_due_at:            bid_due_at + rand(-2..2),
      probability_percent:   rand(35..65),
      included_fire_alarm:   [true, false].sample,
      included_low_voltage:  [true, false].sample,
      base_scope_description: SCOPE_DESCRIPTIONS.sample
    )
  end

  created_rebids << rebid
end

# Create at least one 3-deep rebid chain (rebid of a rebid)
if created_rebids.any?
  second_gen = created_rebids.first
  third_name = "#{second_gen.name} – Round 3"

  unless used_project_names.include?(third_name)
    used_project_names.add(third_name)

    # Mark second gen as lost first
    second_gen.bid_submissions.each do |bid|
      if bid.drafting?
        bid.update_columns(
          status:           BidSubmission.statuses[:lost],
          submitted_value:  rand(200_000..3_000_000).round(-3),
          bid_submitted_at: Date.today - rand(20..45),
          award_decision_at: Date.today - rand(5..15)
        )
      end
    end

    third_gen = Project.create!(
      name:                 third_name,
      location:             second_gen.location,
      project_type:         second_gen.project_type,
      estimated_start_date: Date.today + rand(60..180),
      rebid_of_id:          second_gen.id
    )

    gc_list    = second_gen.bid_submissions.map(&:contractor).uniq
    bid_due_at = Date.today + rand(10..25)

    gc_list.each do |gc|
      third_gen.bid_submissions.create!(
        contractor:            gc,
        user:                  bid_users.sample,
        status:                :drafting,
        bid_due_at:            bid_due_at + rand(-2..2),
        probability_percent:   rand(30..60),
        included_fire_alarm:   [true, false].sample,
        included_low_voltage:  [true, false].sample,
        base_scope_description: SCOPE_DESCRIPTIONS.sample
      )
    end

    puts "    3-deep rebid chain: #{second_gen.rebid_of&.name} → #{second_gen.name} → #{third_gen.name}"
  end
end

puts "    #{created_rebids.size + 1} rebid projects created (including 3rd-round chain)"

# ============================================================
# Summary
# ============================================================

puts ""
puts "Done!"
puts "  Users:          #{User.count}"
puts "  Contractors:    #{Contractor.count}"
puts "  Projects:       #{Project.count}"
puts "  Bid Submissions:#{BidSubmission.count}"
puts ""

status_counts = BidSubmission.group(:status).count
BidSubmission.statuses.each_key do |s|
  puts "    #{s.ljust(12)} #{status_counts[s] || 0}"
end

puts ""
metric_bids = BidSubmission.for_metrics
if metric_bids.any?
  win_rate = BidSubmission.win_rate
  puts "  Win Rate (count): #{win_rate}%"
  puts "  Dollar Win Rate:  #{BidSubmission.dollar_win_rate}%"
end

puts ""
puts "Login: user@example.com / password"
