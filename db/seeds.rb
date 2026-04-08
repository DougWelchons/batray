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
Contact.unscoped.delete_all
Contractor.unscoped.delete_all
User.unscoped.delete_all
Company.unscoped.delete_all

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
  "Temecula, CA"
].freeze

SCOPE_DESCRIPTIONS = [
  "Full electrical scope including service entrance, distribution, lighting, and devices.",
  "Electrical scope per IFC drawings and project specifications.",
  "Complete power and lighting systems including emergency/egress.",
  "Electrical rough and finish per drawings; fire alarm by others.",
  "Full electrical including low voltage rough-in, power, lighting controls.",
  "Service entrance, distribution, branch circuits, lighting, fire alarm, and low voltage.",
  "Electrical per Division 26; excludes specialty systems.",
  "Complete electrical systems including switchgear, panels, lighting, and devices."
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
  "Out-of-area GC preference"
].freeze

# ============================================================
# Companies
# ============================================================

puts "  Creating companies..."

company_a = Company.create!(
  name: "Batray Electric",
  subdomain: "batray",
  active: true
)

company_b = Company.create!(
  name: "Stingray Electrical Services",
  subdomain: "stingray",
  active: true
)

puts "  #{Company.count} companies created"

# ============================================================
# Users
# ============================================================

puts "  Creating users..."

# Company A users
admin = User.create!(
  name: "John Wilson",
  email: "user@example.com",
  role: :admin,
  password: "password",
  password_confirmation: "password",
  company: company_a
)

estimators_a = [
  { name: "Sarah Chen",    email: "sarah.chen@batray.com",    role: :estimator },
  { name: "Mike Torres",   email: "mike.torres@batray.com",   role: :estimator },
  { name: "Jen Nakamura",  email: "jen.nakamura@batray.com",  role: :estimator },
  { name: "Carlos Reyes",  email: "carlos.reyes@batray.com",  role: :estimator },
  { name: "Lisa Grant",    email: "lisa.grant@batray.com",    role: :viewer    }
].map do |attrs|
  User.create!(
    name: attrs[:name],
    email: attrs[:email],
    role: attrs[:role],
    password: "password",
    password_confirmation: "password",
    company: company_a
  )
end

# Company B users
admin_b = User.create!(
  name: "Rachel Martinez",
  email: "rachel@stingray.com",
  role: :admin,
  password: "password",
  password_confirmation: "password",
  company: company_b
)

estimators_b = [
  { name: "David Park",     email: "david.park@stingray.com",     role: :estimator },
  { name: "Emma Johnson",   email: "emma.johnson@stingray.com",   role: :estimator },
  { name: "James Liu",      email: "james.liu@stingray.com",      role: :estimator }
].map do |attrs|
  User.create!(
    name: attrs[:name],
    email: attrs[:email],
    role: attrs[:role],
    password: "password",
    password_confirmation: "password",
    company: company_b
  )
end

# Users who appear on bids (estimators only)
bid_users_a = [ admin ] + estimators_a.select { |u| u.estimator? }
bid_users_b = [ admin_b ] + estimators_b.select { |u| u.estimator? }

puts "  #{User.count} users (Company A: #{company_a.users.count}, Company B: #{company_b.users.count})"

# ============================================================
# Contractors (GCs) – 15 San Diego / Southern CA firms
# ============================================================

puts "  Creating contractors..."

gc_data = [
  { name: "McCarthy Building Companies",  phone: "619-555-0101" },
  { name: "Rudolph and Sletten",          phone: "619-555-0118" },
  { name: "Turner Construction",          phone: "619-555-0134" },
  { name: "DPR Construction",             phone: "619-555-0152" },
  { name: "Hensel Phelps",                phone: "858-555-0167" },
  { name: "Kitchell Contractors",         phone: "619-555-0183" },
  { name: "Clark Construction Group",     phone: "858-555-0199" },
  { name: "Swinerton Builders",           phone: "619-555-0214" },
  { name: "Balfour Beatty Construction",  phone: "858-555-0230" },
  { name: "Sundt Construction",           phone: "619-555-0247" },
  { name: "Webcor Builders",              phone: "858-555-0261" },
  { name: "Skanska USA Building",         phone: "619-555-0278" },
  { name: "Gilbane Building Company",     phone: "619-555-0293" },
  { name: "Soltek Pacific Construction",  phone: "619-555-0309" },
  { name: "Lusardi Construction",         phone: "760-555-0324" }
].freeze

# Split contractors between companies
gc_data_a = gc_data[0..9]  # First 10 for Company A
gc_data_b = gc_data[10..14] # Last 5 for Company B

contractors_a = gc_data_a.map do |attrs|
  Contractor.create!(
    name:    attrs[:name],
    phone:   attrs[:phone],
    company: company_a
  )
end

contractors_b = gc_data_b.map do |attrs|
  Contractor.create!(
    name:    attrs[:name],
    phone:   attrs[:phone],
    company: company_b
  )
end

contractors = contractors_a + contractors_b

puts "  #{Contractor.count} contractors (Company A: #{contractors_a.count}, Company B: #{contractors_b.count})"

# ============================================================
# Contacts – 2-5 per contractor
# ============================================================

puts "  Creating contacts..."

contact_first_names = [
  "Brian", "Diane", "Paul", "Carla", "Brad", "Greg", "Tamara", "Nate", "Renee", "Victor",
  "Amy", "Derek", "Monica", "James", "Rachel", "Kevin", "Linda", "Michael", "Sarah", "Tom",
  "Jessica", "David", "Emily", "Chris", "Ashley", "Matt", "Lauren", "Andrew", "Nicole", "Ryan"
]

contact_last_names = [
  "Holloway", "Park", "Marsh", "Diaz", "Kowalski", "Salazar", "Wells", "Fujimoto", "Albright", "Olsen",
  "Vance", "Finch", "Stein", "Okafor", "Torrez", "Martinez", "Chen", "Rodriguez", "Anderson", "Thompson",
  "Garcia", "Wilson", "Lee", "Taylor", "Brown", "Davis", "Miller", "Moore", "Jackson", "White"
]

total_contacts = 0

contractors.each do |contractor|
  contact_count = rand(2..5)

  contact_count.times do |i|
    first_name = contact_first_names.sample
    last_name = contact_last_names.sample
    name = "#{first_name} #{last_name}"

    # Generate unique email using index to avoid duplicates
    email = "#{first_name.downcase}.#{last_name.downcase}#{i > 0 ? i : ''}@#{contractor.name.parameterize}.com"

    # Vary phone slightly from contractor phone
    base_phone = contractor.phone.gsub(/\D/, '')
    varied_phone = base_phone[0..-3] + rand(10..99).to_s

    Contact.create!(
      contractor: contractor,
      name: name,
      email: email,
      phone: varied_phone
    )

    total_contacts += 1
  end
end

puts "  #{Contact.count} contacts created"

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
  "Office"       => [ "Office Park", "Corporate Center", "Tech Hub", "Business Center", "Professional Plaza", "Office Building", "Innovation Campus" ],
  "Medical"      => [ "Medical Center", "Medical Office Building", "Health Pavilion", "Surgery Center", "Medical Campus", "Outpatient Clinic", "Medical Plaza" ],
  "Industrial"   => [ "Distribution Center", "Logistics Hub", "Warehouse Facility", "Manufacturing Plant", "Industrial Park", "Fulfillment Center", "Cold Storage Facility" ],
  "Retail"       => [ "Retail Center", "Shopping Plaza", "Lifestyle Center", "Retail Village", "Mixed-Use Retail", "Strip Mall Renovation", "Big Box Anchor" ],
  "Education"    => [ "Elementary School", "Middle School", "High School Modernization", "Community College Building", "University Research Hall", "STEM Center", "Library & Learning Commons" ],
  "Hospitality"  => [ "Hotel & Conference Center", "Extended Stay Hotel", "Boutique Hotel Renovation", "Resort Expansion", "Marriott Renovation", "Hotel Tower" ],
  "Data Center"  => [ "Data Center – Phase 1", "Data Center – Phase 2", "Colocation Facility", "Network Operations Center", "Edge Data Center", "Server Farm Build-Out" ],
  "Multifamily"  => [ "Apartment Complex", "Mixed-Use Residential Tower", "Senior Living Community", "Affordable Housing", "Market-Rate Apartments", "Townhome Development", "Student Housing" ]
}.freeze

used_project_names = Set.new

def generate_project_name(type, used_names)
  prefixes = SD_PROJECT_PREFIXES.dup.shuffle
  suffixes = SD_PROJECT_SUFFIXES[type] || [ "Building" ]
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
      included_fire_alarm:   [ true, false ].sample,
      included_low_voltage:  [ true, false ].sample,
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
      outcomes[idx] = [ :withdrawn, :declined ].sample
    end

  when :lost
    # All lost, occasional withdrawn/declined
    outcomes = Array.new(size, :lost)
    (1...size).each do |i|
      outcomes[i] = [ :withdrawn, :declined ].sample if rand < 0.12
    end

  when :pending
    # All submitted, occasional lost/withdrawn among them
    outcomes = Array.new(size, :submitted)
    (1...size).each do |i|
      if rand < 0.15
        outcomes[i] = [ :lost, :withdrawn, :declined ].sample
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
                         contractors:, bid_users:, used_names:, company:)
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
      estimated_start_date: start_date,
      company:              company
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
# THIS YEAR – ~89 projects for Company A, ~40 for Company B
# 20% awarded, 55% lost, 25% pending
# ============================================================

puts "  Creating this year's projects..."

this_year_projects_a = create_project_batch(
  count:       89,
  year_offset: 0,
  won_pct:     0.20,
  lost_pct:    0.55,
  pending_pct: 0.25,
  contractors: contractors_a,
  bid_users:   bid_users_a,
  used_names:  used_project_names,
  company:     company_a
)

this_year_projects_b = create_project_batch(
  count:       40,
  year_offset: 0,
  won_pct:     0.20,
  lost_pct:    0.55,
  pending_pct: 0.25,
  contractors: contractors_b,
  bid_users:   bid_users_b,
  used_names:  used_project_names,
  company:     company_b
)

puts "    Company A: #{this_year_projects_a.size} projects, Company B: #{this_year_projects_b.size} projects"

# ============================================================
# LAST YEAR – ~75 projects for Company A, ~35 for Company B
# 25% awarded, 75% lost (a few declined/withdrawn mixed in)
# pending_pct: 0 – all resolved
# ============================================================

puts "  Creating last year's projects..."

last_year_projects_a = create_project_batch(
  count:       75,
  year_offset: 1,
  won_pct:     0.25,
  lost_pct:    0.75,
  pending_pct: 0.00,
  contractors: contractors_a,
  bid_users:   bid_users_a,
  used_names:  used_project_names,
  company:     company_a
)

last_year_projects_b = create_project_batch(
  count:       35,
  year_offset: 1,
  won_pct:     0.25,
  lost_pct:    0.75,
  pending_pct: 0.00,
  contractors: contractors_b,
  bid_users:   bid_users_b,
  used_names:  used_project_names,
  company:     company_b
)

puts "    Company A: #{last_year_projects_a.size} projects, Company B: #{last_year_projects_b.size} projects"

# ============================================================
# TWO YEARS AGO – ~75 projects for Company A, ~35 for Company B
# 25% awarded, 75% lost (same ratios)
# ============================================================

puts "  Creating two-years-ago projects..."

two_years_ago_projects_a = create_project_batch(
  count:       75,
  year_offset: 2,
  won_pct:     0.25,
  lost_pct:    0.75,
  pending_pct: 0.00,
  contractors: contractors_a,
  bid_users:   bid_users_a,
  used_names:  used_project_names,
  company:     company_a
)

two_years_ago_projects_b = create_project_batch(
  count:       35,
  year_offset: 2,
  won_pct:     0.25,
  lost_pct:    0.75,
  pending_pct: 0.00,
  contractors: contractors_b,
  bid_users:   bid_users_b,
  used_names:  used_project_names,
  company:     company_b
)

puts "    Company A: #{two_years_ago_projects_a.size} projects, Company B: #{two_years_ago_projects_b.size} projects"

# ============================================================
# DRAFTING PROJECTS – 20 for Company A, 10 for Company B
#
# Due date urgency:
#   4 projects: due within next 2 days
#   2 projects: overdue by a few days
#   14 projects: due in the future (1–6 weeks out)
#
# Most bids still in :drafting; some projects have no bids yet.
# ============================================================

puts "  Creating drafting projects..."

def create_drafting_projects(count:, contractors:, bid_users:, used_names:, company:)
  due_date_configs = [
    # [date_offset_days, label]
    *Array.new((count * 0.2).to_i)  { [ rand(0..2),   :warning ] },   # due within 2 days
    *Array.new((count * 0.1).to_i)  { [ -rand(2..5),  :overdue ] },    # overdue
    *Array.new((count * 0.7).to_i)  { [ rand(5..42),  :future ]  }    # future
  ].shuffle

  due_date_configs.each_with_index do |config, i|
    days_offset = config[0]
    bid_due_at  = Date.today + days_offset

    type     = PROJECT_TYPES.sample
    location = SD_LOCATIONS.sample
    name     = generate_project_name(type, used_names)

    project = Project.create!(
      name:                 name,
      location:             location,
      project_type:         type,
      estimated_start_date: Date.today + rand(60..300),
      company:              company
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
        included_fire_alarm:   [ true, false ].sample,
        included_low_voltage:  [ true, false ].sample,
        base_scope_description: SCOPE_DESCRIPTIONS.sample
      )
    end
  end
end

create_drafting_projects(
  count: 20,
  contractors: contractors_a,
  bid_users: bid_users_a,
  used_names: used_project_names,
  company: company_a
)

create_drafting_projects(
  count: 10,
  contractors: contractors_b,
  bid_users: bid_users_b,
  used_names: used_project_names,
  company: company_b
)

puts "    Company A: 20 drafting projects, Company B: 10 drafting projects"

# ============================================================
# NOTE: Rebids omitted for simplicity in this seed file.
# The rebid_of_id feature is available but not seeded.
# ============================================================

# ============================================================
# Summary
# ============================================================

puts ""
puts "Done!"
puts "  Companies:      #{Company.count}"
puts "  Users:          #{User.count}"
puts "  Contractors:    #{Contractor.count}"
puts "  Contacts:       #{Contact.count}"
puts "  Projects:       #{Project.count}"
puts "  Bid Submissions:#{BidSubmission.count}"
puts ""

puts "  Company A (Batray Electric):"
puts "    Projects:       #{company_a.projects.count}"
puts "    Contractors:    #{company_a.contractors.count}"
puts "    Users:          #{company_a.users.count}"
puts ""

puts "  Company B (Stingray Electrical):"
puts "    Projects:       #{company_b.projects.count}"
puts "    Contractors:    #{company_b.contractors.count}"
puts "    Users:          #{company_b.users.count}"
puts ""

status_counts = BidSubmission.group(:status).count
BidSubmission.statuses.each_key do |s|
  puts "    #{s.ljust(12)} #{status_counts[s] || 0}"
end

puts ""
puts "Login credentials:"
puts "  Company A: user@example.com / password"
puts "  Company B: rachel@stingray.com / password"
