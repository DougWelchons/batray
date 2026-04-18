# Seeds – idempotent, safe to re-run
# Covers: ~15 GCs, 6 users, 20 drafting, ~89 this year, ~75 last year, ~75 two years ago
# Rebid chains, correct win/loss ratios, San Diego area locations

puts "Seeding database..."
puts "  Clearing existing data..."

# Clear in dependency order so we can re-run safely
BidSubmission.unscoped.delete_all
ProjectsClassification.delete_all
Project.unscoped.delete_all
Classification.delete_all
Contact.unscoped.delete_all
Contractor.unscoped.delete_all
User.unscoped.delete_all
Company.unscoped.delete_all

# ============================================================
# Constants / lookup data
# ============================================================

PROJECT_TYPES = %w[Office Medical Industrial Retail Education Hospitality Data\ Center Multifamily].freeze

SD_LOCATIONS = [
  { street: "550 West C St",         city: "San Diego",     state: "CA", zip_code: "92101" },
  { street: "2550 Fifth Ave",         city: "San Diego",     state: "CA", zip_code: "92103" },
  { street: "9444 Waples St",         city: "San Diego",     state: "CA", zip_code: "92121" },
  { street: "690 Vía de la Valle",    city: "Chula Vista",   state: "CA", zip_code: "91910" },
  { street: "1390 N Marshall Ave",    city: "El Cajon",      state: "CA", zip_code: "92020" },
  { street: "500 Washington Ave",     city: "Escondido",     state: "CA", zip_code: "92025" },
  { street: "9500 Cuyamaca St",       city: "Santee",        state: "CA", zip_code: "92071" },
  { street: "7911 University Ave",    city: "La Mesa",       state: "CA", zip_code: "91942" },
  { street: "1430 National City Blvd", city: "National City", state: "CA", zip_code: "91950" },
  { street: "12335 World Trade Dr",   city: "Poway",         state: "CA", zip_code: "92064" },
  { street: "300 N Tremont St",       city: "Oceanside",     state: "CA", zip_code: "92054" },
  { street: "2251 Rutherford Rd",     city: "Carlsbad",      state: "CA", zip_code: "92008" },
  { street: "1550 S Melrose Dr",      city: "Vista",         state: "CA", zip_code: "92083" },
  { street: "1 Civic Center Dr",      city: "San Marcos",    state: "CA", zip_code: "92078" },
  { street: "600 Mission Ave",        city: "Encinitas",     state: "CA", zip_code: "92024" },
  { street: "100 B Ave",              city: "Coronado",      state: "CA", zip_code: "92118" },
  { street: "3233 Lemon Grove Ave",   city: "Lemon Grove",   state: "CA", zip_code: "91945" },
  { street: "8363 Center Dr",         city: "Spring Valley", state: "CA", zip_code: "91977" },
  { street: "12750 Lakeshore Dr",     city: "Lakeside",      state: "CA", zip_code: "92040" },
  { street: "1430 Montecito Rd",      city: "Ramona",        state: "CA", zip_code: "92065" },
  { street: "200 N Spring St",        city: "Los Angeles",   state: "CA", zip_code: "90012" },
  { street: "3900 Main St",           city: "Riverside",     state: "CA", zip_code: "92501" },
  { street: "28720 Via Montezuma",    city: "Temecula",      state: "CA", zip_code: "92590" }
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

CONTACT_ROLES = %w[Project\ Manager Estimator Principal VP\ of\ Operations Field\ Superintendent].freeze

# ============================================================
# Companies
# ============================================================

puts "  Creating companies..."

company_a = Company.create!(
  name:     "Batray Electric",
  street:   "9444 Waples St, Suite 200",
  city:     "San Diego",
  state:    "CA",
  zip_code: "92121",
  phone:    "619-555-0100",
  active:   true
)

company_b = Company.create!(
  name:     "Stingray Electrical Services",
  street:   "550 West C St, Suite 800",
  city:     "San Diego",
  state:    "CA",
  zip_code: "92101",
  phone:    "619-555-0200",
  active:   true
)

puts "  #{Company.count} companies created"

# ============================================================
# Users
# ============================================================

puts "  Creating users..."

# Company A users
admin = User.create!(
  first_name:            "John",
  last_name:             "Wilson",
  email:                 "user@example.com",
  role:                  :admin,
  password:              "password",
  password_confirmation: "password",
  company:               company_a
)

estimators_a = [
  { first_name: "Sarah",  last_name: "Chen",    email: "sarah.chen@batray.com",   role: :estimator },
  { first_name: "Mike",   last_name: "Torres",  email: "mike.torres@batray.com",  role: :estimator },
  { first_name: "Jen",    last_name: "Nakamura", email: "jen.nakamura@batray.com", role: :estimator },
  { first_name: "Carlos", last_name: "Reyes",   email: "carlos.reyes@batray.com", role: :estimator },
  { first_name: "Lisa",   last_name: "Grant",   email: "lisa.grant@batray.com",   role: :viewer    }
].map do |attrs|
  User.create!(
    first_name:            attrs[:first_name],
    last_name:             attrs[:last_name],
    email:                 attrs[:email],
    role:                  attrs[:role],
    password:              "password",
    password_confirmation: "password",
    company:               company_a
  )
end

# Company B users
admin_b = User.create!(
  first_name:            "Rachel",
  last_name:             "Martinez",
  email:                 "rachel@stingray.com",
  role:                  :admin,
  password:              "password",
  password_confirmation: "password",
  company:               company_b
)

estimators_b = [
  { first_name: "David", last_name: "Park",    email: "david.park@stingray.com",   role: :estimator },
  { first_name: "Emma",  last_name: "Johnson", email: "emma.johnson@stingray.com", role: :estimator },
  { first_name: "James", last_name: "Liu",     email: "james.liu@stingray.com",    role: :estimator }
].map do |attrs|
  User.create!(
    first_name:            attrs[:first_name],
    last_name:             attrs[:last_name],
    email:                 attrs[:email],
    role:                  attrs[:role],
    password:              "password",
    password_confirmation: "password",
    company:               company_b
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
  { name: "McCarthy Building Companies",  phone: "619-555-0101", street: "9444 Waples St, Suite 300",        city: "San Diego",  state: "CA", zip_code: "92121" },
  { name: "Rudolph and Sletten",          phone: "619-555-0118", street: "5355 Mira Sorrento Pl, Suite 600", city: "San Diego",  state: "CA", zip_code: "92121" },
  { name: "Turner Construction",          phone: "619-555-0134", street: "750 B St, Suite 2800",             city: "San Diego",  state: "CA", zip_code: "92101" },
  { name: "DPR Construction",             phone: "619-555-0152", street: "6340 Sequence Dr, Suite 100",      city: "San Diego",  state: "CA", zip_code: "92121" },
  { name: "Hensel Phelps",                phone: "858-555-0167", street: "11440 W Bernardo Ct, Suite 100",   city: "San Diego",  state: "CA", zip_code: "92127" },
  { name: "Kitchell Contractors",         phone: "619-555-0183", street: "2550 Fifth Ave, Suite 700",        city: "San Diego",  state: "CA", zip_code: "92103" },
  { name: "Clark Construction Group",     phone: "858-555-0199", street: "4435 Eastgate Mall, Suite 200",    city: "San Diego",  state: "CA", zip_code: "92121" },
  { name: "Swinerton Builders",           phone: "619-555-0214", street: "550 West C St, Suite 1500",        city: "San Diego",  state: "CA", zip_code: "92101" },
  { name: "Balfour Beatty Construction",  phone: "858-555-0230", street: "9665 Chesapeake Dr, Suite 335",    city: "San Diego",  state: "CA", zip_code: "92123" },
  { name: "Sundt Construction",           phone: "619-555-0247", street: "2010 Main St, Suite 1200",         city: "San Diego",  state: "CA", zip_code: "92113" },
  { name: "Webcor Builders",              phone: "858-555-0261", street: "4445 Eastgate Mall, Suite 100",    city: "San Diego",  state: "CA", zip_code: "92121" },
  { name: "Skanska USA Building",         phone: "619-555-0278", street: "501 W Broadway, Suite 1700",       city: "San Diego",  state: "CA", zip_code: "92101" },
  { name: "Gilbane Building Company",     phone: "619-555-0293", street: "402 W Broadway, Suite 1000",       city: "San Diego",  state: "CA", zip_code: "92101" },
  { name: "Soltek Pacific Construction",  phone: "619-555-0309", street: "8799 Balboa Ave, Suite 250",       city: "San Diego",  state: "CA", zip_code: "92123" },
  { name: "Lusardi Construction",         phone: "760-555-0324", street: "1570 Linda Vista Dr",              city: "San Marcos", state: "CA", zip_code: "92078" }
].freeze

# Split contractors between companies
gc_data_a = gc_data[0..9]   # First 10 for Company A
gc_data_b = gc_data[10..14] # Last 5 for Company B

contractors_a = gc_data_a.map do |attrs|
  Contractor.create!(
    name:     attrs[:name],
    phone:    attrs[:phone],
    street:   attrs[:street],
    city:     attrs[:city],
    state:    attrs[:state],
    zip_code: attrs[:zip_code],
    company:  company_a
  )
end

contractors_b = gc_data_b.map do |attrs|
  Contractor.create!(
    name:     attrs[:name],
    phone:    attrs[:phone],
    street:   attrs[:street],
    city:     attrs[:city],
    state:    attrs[:state],
    zip_code: attrs[:zip_code],
    company:  company_b
  )
end

contractors = contractors_a + contractors_b

puts "  #{Contractor.count} contractors (Company A: #{contractors_a.count}, Company B: #{contractors_b.count})"

# ============================================================
# Classifications – per company
# ============================================================

puts "  Creating classifications..."

CLASSIFICATION_NAMES = %w[
  Office Medical Industrial Retail Education Hospitality Data\ Center Multifamily
  Mixed-Use Parking Government Healthcare Tenant\ Improvement
].freeze

classifications_a = CLASSIFICATION_NAMES.map do |name|
  Classification.create!(name: name, company: company_a)
end

classifications_b = CLASSIFICATION_NAMES.map do |name|
  Classification.create!(name: name, company: company_b)
end

puts "  #{Classification.count} classifications created"

# ============================================================
# Contacts – 2-5 per contractor
# ============================================================

puts "  Creating contacts..."

contact_first_names = %w[
  Brian Diane Paul Carla Brad Greg Tamara Nate Renee Victor
  Amy Derek Monica James Rachel Kevin Linda Michael Sarah Tom
  Jessica David Emily Chris Ashley Matt Lauren Andrew Nicole Ryan
]

contact_last_names = %w[
  Holloway Park Marsh Diaz Kowalski Salazar Wells Fujimoto Albright Olsen
  Vance Finch Stein Okafor Torrez Martinez Chen Rodriguez Anderson Thompson
  Garcia Wilson Lee Taylor Brown Davis Miller Moore Jackson White
]

contractors.each do |contractor|
  contact_count = rand(2..5)
  used_emails   = Set.new

  contact_count.times do |i|
    first_name = contact_first_names.sample
    last_name  = contact_last_names.sample

    # Build a unique email within this contractor
    base_email = "#{first_name.downcase}.#{last_name.downcase}@#{contractor.name.parameterize}.com"
    email      = used_emails.include?(base_email) ? "#{first_name.downcase}.#{last_name.downcase}#{i}@#{contractor.name.parameterize}.com" : base_email
    used_emails.add(email)

    base_phone   = contractor.phone.gsub(/\D/, "")
    varied_phone = "#{base_phone[0..-3]}#{rand(10..99)}"

    Contact.create!(
      contractor: contractor,
      first_name: first_name,
      last_name:  last_name,
      email:      email,
      phone:      varied_phone,
      role:       CONTACT_ROLES.sample
    )
  end
end

puts "  #{Contact.count} contacts created"

# ============================================================
# Project name generation – realistic SD-area construction
# ============================================================

SD_PROJECT_PREFIXES = %w[
  Balboa Gaslamp Cabrillo Coronado Torrey\ Pines Miramar
  Kearny\ Mesa Mission\ Valley Otay\ Ranch Chula\ Vista Rancho\ Bernardo
  Sorrento\ Valley Carmel\ Valley Scripps\ Ranch La\ Jolla Point\ Loma
  Eastlake Bonita Escondido El\ Cajon Carlsbad Oceanside
  San\ Marcos Vista Poway Santee Alpine Spring\ Valley
  National\ City Lemon\ Grove Encinitas Solana\ Beach Del\ Mar
  Temecula Murrieta Riverside Burbank Glendale
].freeze

SD_PROJECT_SUFFIXES = {
  "Office"      => [ "Office Park", "Corporate Center", "Tech Hub", "Business Center", "Professional Plaza", "Office Building", "Innovation Campus" ],
  "Medical"     => [ "Medical Center", "Medical Office Building", "Health Pavilion", "Surgery Center", "Medical Campus", "Outpatient Clinic", "Medical Plaza" ],
  "Industrial"  => [ "Distribution Center", "Logistics Hub", "Warehouse Facility", "Manufacturing Plant", "Industrial Park", "Fulfillment Center", "Cold Storage Facility" ],
  "Retail"      => [ "Retail Center", "Shopping Plaza", "Lifestyle Center", "Retail Village", "Mixed-Use Retail", "Strip Mall Renovation", "Big Box Anchor" ],
  "Education"   => [ "Elementary School", "Middle School", "High School Modernization", "Community College Building", "University Research Hall", "STEM Center", "Library & Learning Commons" ],
  "Hospitality" => [ "Hotel & Conference Center", "Extended Stay Hotel", "Boutique Hotel Renovation", "Resort Expansion", "Marriott Renovation", "Hotel Tower" ],
  "Data Center" => [ "Data Center – Phase 1", "Data Center – Phase 2", "Colocation Facility", "Network Operations Center", "Edge Data Center", "Server Farm Build-Out" ],
  "Multifamily" => [ "Apartment Complex", "Mixed-Use Residential Tower", "Senior Living Community", "Affordable Housing", "Market-Rate Apartments", "Townhome Development", "Student Housing" ]
}.freeze

used_project_names = Set.new

def generate_project_name(type, used_names)
  suffixes = SD_PROJECT_SUFFIXES[type] || [ "Building" ]
  loop do
    name = "#{SD_PROJECT_PREFIXES.sample} #{suffixes.sample}"
    next if used_names.include?(name)
    used_names.add(name)
    return name
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

  gc_list.each_with_index do |gc, i|
    status = outcomes[i]
    submitted_value   = rand_value_cluster(base_value)
    awarded_value     = nil
    award_decision_at = nil

    if status == :awarded
      awarded_value     = (submitted_value * rand(0.93..1.06)).round(-3)
      award_decision_at = bid_submitted_at + rand(30..90)
    elsif status == :lost
      award_decision_at = bid_submitted_at + rand(30..90)
    end

    this_bid_due = bid_due_at + rand(-2..2)

    project.bid_submissions.create!(
      contractor:             gc,
      contact:                gc.contacts.sample,
      user:                   bid_users.sample,
      status:                 status,
      bid_submitted_at:       bid_submitted_at,
      bid_due_at:             this_bid_due,
      award_decision_at:      award_decision_at,
      submitted_value:        submitted_value,
      awarded_value:          awarded_value,
      probability_percent:    status == :awarded ? rand(55..85) : (status == :lost ? rand(10..45) : rand(35..65)),
      reason_lost:            status == :lost ? REASONS_LOST.sample : nil,
      base_scope_description: SCOPE_DESCRIPTIONS.sample
    )
  end
end

# ============================================================
# Helper: assign outcomes for a batch of projects
# ============================================================

def assign_project_outcomes(gc_list, mode:)
  size = gc_list.size

  case mode
  when :awarded
    outcomes = Array.new(size, :lost)
    outcomes[0] = :awarded
    if size > 2 && rand < 0.25
      outcomes[(1...size).to_a.sample] = [ :withdrawn, :declined ].sample
    end
  when :lost
    outcomes = Array.new(size, :lost)
    (1...size).each { |i| outcomes[i] = [ :withdrawn, :declined ].sample if rand < 0.12 }
  when :pending
    outcomes = Array.new(size, :submitted)
    (1...size).each { |i| outcomes[i] = [ :lost, :withdrawn, :declined ].sample if rand < 0.15 }
  end

  outcomes.shuffle
end

# ============================================================
# Generate a batch of projects
# ============================================================

def create_project_batch(count:, year_offset:, won_pct:, lost_pct:, pending_pct:,
                         contractors:, bid_users:, classifications:, used_names:, company:)
  year_start = Date.new(Date.today.year - year_offset, 1, 1)
  year_end   = year_offset.zero? ? Date.today - 1 : Date.new(Date.today.year - year_offset, 12, 31)

  projects = []

  count.times do
    r    = rand
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
      street:               location[:street],
      city:                 location[:city],
      state:                location[:state],
      zip_code:             location[:zip_code],
      estimated_start_date: start_date,
      company:              company
    )

    classification_count = [ 0, 1, 1, 1, 1, 2, 2, 3 ].sample
    project.classifications << classifications.sample(classification_count) if classification_count > 0

    gc_count = rand(1..6)
    gc_list  = contractors.sample(gc_count)
    outcomes = assign_project_outcomes(gc_list, mode: mode)

    # Past pending projects must be resolved
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
# ============================================================

puts "  Creating this year's projects..."

this_year_projects_a = create_project_batch(
  count: 89, year_offset: 0, won_pct: 0.20, lost_pct: 0.55, pending_pct: 0.25,
  contractors: contractors_a, bid_users: bid_users_a, classifications: classifications_a,
  used_names: used_project_names, company: company_a
)

this_year_projects_b = create_project_batch(
  count: 40, year_offset: 0, won_pct: 0.20, lost_pct: 0.55, pending_pct: 0.25,
  contractors: contractors_b, bid_users: bid_users_b, classifications: classifications_b,
  used_names: used_project_names, company: company_b
)

puts "    Company A: #{this_year_projects_a.size} projects, Company B: #{this_year_projects_b.size} projects"

# ============================================================
# LAST YEAR – ~75 projects for Company A, ~35 for Company B
# ============================================================

puts "  Creating last year's projects..."

last_year_projects_a = create_project_batch(
  count: 75, year_offset: 1, won_pct: 0.25, lost_pct: 0.75, pending_pct: 0.00,
  contractors: contractors_a, bid_users: bid_users_a, classifications: classifications_a,
  used_names: used_project_names, company: company_a
)

last_year_projects_b = create_project_batch(
  count: 35, year_offset: 1, won_pct: 0.25, lost_pct: 0.75, pending_pct: 0.00,
  contractors: contractors_b, bid_users: bid_users_b, classifications: classifications_b,
  used_names: used_project_names, company: company_b
)

puts "    Company A: #{last_year_projects_a.size} projects, Company B: #{last_year_projects_b.size} projects"

# ============================================================
# TWO YEARS AGO – ~75 projects for Company A, ~35 for Company B
# ============================================================

puts "  Creating two-years-ago projects..."

two_years_ago_projects_a = create_project_batch(
  count: 75, year_offset: 2, won_pct: 0.25, lost_pct: 0.75, pending_pct: 0.00,
  contractors: contractors_a, bid_users: bid_users_a, classifications: classifications_a,
  used_names: used_project_names, company: company_a
)

two_years_ago_projects_b = create_project_batch(
  count: 35, year_offset: 2, won_pct: 0.25, lost_pct: 0.75, pending_pct: 0.00,
  contractors: contractors_b, bid_users: bid_users_b, classifications: classifications_b,
  used_names: used_project_names, company: company_b
)

puts "    Company A: #{two_years_ago_projects_a.size} projects, Company B: #{two_years_ago_projects_b.size} projects"

# ============================================================
# DRAFTING PROJECTS – 20 for Company A, 10 for Company B
# ============================================================

puts "  Creating drafting projects..."

def create_drafting_projects(count:, contractors:, bid_users:, classifications:, used_names:, company:)
  due_date_configs = [
    *Array.new((count * 0.2).to_i) { rand(0..2)  },   # due within 2 days
    *Array.new((count * 0.1).to_i) { -rand(2..5) },    # overdue
    *Array.new((count * 0.7).to_i) { rand(5..42) }     # future
  ].shuffle

  due_date_configs.each_with_index do |days_offset, i|
    bid_due_at = Date.today + days_offset
    type       = PROJECT_TYPES.sample
    location   = SD_LOCATIONS.sample
    name       = generate_project_name(type, used_names)

    project = Project.create!(
      name:                 name,
      street:               location[:street],
      city:                 location[:city],
      state:                location[:state],
      zip_code:             location[:zip_code],
      estimated_start_date: Date.today + rand(60..300),
      company:              company
    )

    classification_count = [ 0, 1, 1, 1, 1, 2, 2, 3 ].sample
    project.classifications << classifications.sample(classification_count) if classification_count > 0

    # First 3 projects have no bids yet
    next if i <= 2

    gc_list    = contractors.sample(rand(1..6))
    base_value = rand(150_000..4_500_000).round(-3)

    gc_list.each do |gc|
      status           = rand < 0.85 ? :drafting : :submitted
      submitted_value  = status == :submitted ? rand_value_cluster(base_value) : nil
      bid_submitted_at = status == :submitted ? bid_due_at - rand(1..5) : nil

      project.bid_submissions.create!(
        contractor:             gc,
        contact:                gc.contacts.sample,
        user:                   bid_users.sample,
        status:                 status,
        bid_due_at:             bid_due_at + rand(-2..2),
        bid_submitted_at:       bid_submitted_at,
        submitted_value:        submitted_value,
        probability_percent:    rand(40..70),
        base_scope_description: SCOPE_DESCRIPTIONS.sample
      )
    end
  end
end

create_drafting_projects(
  count: 20, contractors: contractors_a, bid_users: bid_users_a,
  classifications: classifications_a, used_names: used_project_names, company: company_a
)

create_drafting_projects(
  count: 10, contractors: contractors_b, bid_users: bid_users_b,
  classifications: classifications_b, used_names: used_project_names, company: company_b
)

puts "    Company A: 20 drafting projects, Company B: 10 drafting projects"

# ============================================================
# Summary
# ============================================================

puts ""
puts "Done!"
puts "  Companies:       #{Company.count}"
puts "  Users:           #{User.count}"
puts "  Contractors:     #{Contractor.count}"
puts "  Contacts:        #{Contact.count}"
puts "  Projects:        #{Project.count}"
puts "  Bid Submissions: #{BidSubmission.count}"
puts ""
puts "  Company A (Batray Electric):"
puts "    Projects:    #{company_a.projects.count}"
puts "    Contractors: #{company_a.contractors.count}"
puts "    Users:       #{company_a.users.count}"
puts ""
puts "  Company B (Stingray Electrical):"
puts "    Projects:    #{company_b.projects.count}"
puts "    Contractors: #{company_b.contractors.count}"
puts "    Users:       #{company_b.users.count}"
puts ""

status_counts = BidSubmission.unscoped.group(:status).count
BidSubmission.statuses.each_key do |s|
  puts "    #{s.ljust(12)} #{status_counts[s] || 0}"
end

puts ""
puts "Login credentials:"
puts "  Company A: user@example.com / password"
puts "  Company B: rachel@stingray.com / password"
