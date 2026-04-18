# Electrical Contractor Bid Tracking System

## Rails 8 Internal Application – Architecture & Build Plan

---

# 1. Project Goal

Build a Ruby on Rails web application for a single electrical contractor to:

* Track construction projects
* Track bid submissions to multiple General Contractors (GCs)
* Track scope variations per GC
* Track bid outcomes (won/lost/etc.)
* Analyze performance metrics over time

### Constraints

* ~25 internal users
* ~50 projects per month
* Multiple bid submissions per project
* Internal tool (no public access)
* Must minimize data entry friction
* Must maintain clean analytics

---

# 2. Core Domain Principle

### The fundamental business unit is:

> A **BidSubmission** (our bid to a specific GC for a specific project)

* A **Project** groups related bids.
* All reporting aggregates from **BidSubmission**.
* The system must treat BidSubmission as the core analytical entity.

---

# 3. Primary Data Model

---

## Project

Represents a real-world construction project.

```ruby
Project
- id
- name (required)
- location
- project_type
- estimated_start_date
- rebid_of_id (optional, self-reference)
- created_at
- updated_at
- discarded_at (soft delete)
```

### Associations

```ruby
has_many :bid_submissions, dependent: :destroy
belongs_to :rebid_of, class_name: "Project", optional: true
```

---

## Contractor (General Contractor)

```ruby
Contractor
- id
- name (required, unique)
- contact_name
- email
- phone
- notes
- created_at
- updated_at
```

---

## BidSubmission (Core Entity)

Represents one bid sent to one GC.

```ruby
BidSubmission
- id
- project_id (required)
- contractor_id (required)
- user_id (estimator)
- status (enum)
- bid_submitted_at
- bid_due_at
- award_decision_at
- submitted_value (decimal)
- awarded_value (decimal)
- probability_percent (default: 50)
- included_fire_alarm (boolean)
- included_low_voltage (boolean)
- base_scope_description (text)
- reason_lost (string)
- notes (text)
- created_at
- updated_at
- discarded_at
```

### Associations

```ruby
belongs_to :project
belongs_to :contractor
belongs_to :user
```

---

## User

Use Devise for authentication.

```ruby
User
- id
- name
- email
- role (enum: admin, estimator, viewer)
- created_at
- updated_at
```

---

# 4. Status Lifecycle

```ruby
enum status: {
  drafting: 0,
  submitted: 1,
  awarded: 2,
  lost: 3,
  withdrawn: 4,
  declined: 5
}
```

### Rules

* `submitted_value` required when status >= submitted
* `awarded_value` required when status == awarded
* `award_decision_at` required when awarded or lost
* `withdrawn` and `declined` excluded from win rate metrics
* `drafting` excluded from all metrics

---

# 5. Reporting Definitions (Locked Before Build)

---

## Win Rate (Count-Based)

```
awarded / submitted
```

Where:

* `submitted` includes: submitted, awarded, lost
* Excludes: drafting, withdrawn, declined

---

## Dollar Win Rate

```
SUM(awarded_value) / SUM(submitted_value)
```

---

## Monthly Awarded Revenue

Grouped by:

```
DATE_TRUNC('month', award_decision_at)
```

---

## Monthly Bid Volume

Grouped by:

```
DATE_TRUNC('month', bid_submitted_at)
```

---

# 6. Database Constraints & Indexing

### Indexes

```ruby
index :bid_submissions, :project_id
index :bid_submissions, :contractor_id
index :bid_submissions, :status
index :bid_submissions, :bid_submitted_at
index :bid_submissions, :award_decision_at
index :projects, :rebid_of_id
```

### Validations

* `submitted_value > 0`
* `awarded_value > 0` if status == awarded
* `award_decision_at >= bid_submitted_at`
* Uniqueness constraint on `[project_id, contractor_id]`

---

# 7. Soft Delete Policy

Use the `discard` gem.

Never hard delete:

* Projects
* BidSubmissions

Historical reporting must remain accurate.

---

# 8. UI / Workflow Design Principles

## Primary Objective

> Under 60 seconds to log a project with 2 GC bids.

---

## Create Project Page

Single screen:

### Section 1 – Project Info

* Project Name
* Location
* Type
* Estimated Start Date

### Section 2 – Bid Submissions (Dynamic Rows)

| GC | Bid Date | Value | FA | LV | Status |
| -- | -------- | ----- | -- | -- | ------ |

* “Add GC” button
* Nested attributes
* Stimulus for dynamic row addition
* Turbo for smooth updates

---

## Editing Workflow

* Project show page lists all GC bids
* Inline status changes
* Inline awarded value entry
* Minimal page reloads

---

## Duplicate Feature

Allow:

> “Duplicate Project with All GC Bids”

When duplicating:

* Reset status to `drafting`
* Clear dates
* Clear awarded values

Critical for rebids.

---

# 9. Permissions

Use Pundit.

## Roles

### Admin

* Full CRUD
* Manage users

### Estimator

* Create and edit projects
* Edit own bid submissions
* No delete permissions

### Viewer

* Read-only access to dashboards

---

# 10. Dashboard (MVP)

### Summary Cards

* Total Bids YTD
* Total Awarded YTD
* Win Rate %
* Dollar Win Rate %

### Charts

* Bids per month
* Awarded $ per month
* Win rate by GC

### Tools

* Chartkick
* PostgreSQL aggregations

No separate analytics engine.

---

# 11. Performance Expectations

Projected volume:

* ~200 bid submissions/month
* ~3,000/year
* ~15,000 over 5 years

PostgreSQL easily supports this scale.

No special scaling architecture required.

---

# 12. Phase 2 (Not in MVP)

Potential future enhancements:

* BidRevision model
* ScopeItem join model
* Forecasted revenue dashboard
* CSV export
* Advanced filtering UI
* Email reminders
* API endpoints

Architecture must allow extension without refactoring core models.

---

# 13. Technical Stack

* Rails 8
* PostgreSQL
* Devise (authentication)
* Pundit (authorization)
* Discard (soft delete)
* Chartkick (charts)
* Stimulus (dynamic forms)
* Turbo (UX)

---

# 14. Non-Goals (Prevent Scope Creep)

* No accounting integration
* No document management
* No file storage (MVP)
* No CRM system
* No complex cost breakdown logic
* No external API integrations

---

# 15. Development Order

1. Rails app setup
2. Devise configuration
3. Contractor CRUD
4. Project + nested BidSubmission
5. Status enum & validations
6. Soft delete implementation
7. Dashboard metrics
8. Charts
9. Authorization rules

---

# 16. Success Criteria

The application succeeds if:

* Estimators consistently use it
* Logging bids takes < 60 seconds
* Leadership can answer:

  * Which GCs do we win most with?
  * What is our YTD win rate?
  * What is awarded revenue by quarter?
  * Are we overbidding unproductive GCs?

---

# Design Enforcement Rule

All UI, layout, styling, and component decisions MUST strictly follow the
`claude_design_guide.md` file.

The design guide is the single source of truth for:

- Color tokens
- Typography
- Spacing system
- Border radius
- Shadows
- Component structure
- Light/Dark mode implementation
- Interaction states (hover, focus, active)
- Status color usage
- Layout rules

## Hard Requirements

1. Never introduce new colors outside of the defined token system.
2. Never hardcode hex values directly in components.
3. Always use semantic design tokens (e.g., `--color-accent`, `--color-bg-surface`).
4. All components must support both light and dark mode.
5. Follow spacing scale strictly (no arbitrary padding/margin values).
6. Avoid excessive decoration — prioritize clarity and hierarchy.
7. Maintain a clean, professional, muted aesthetic at all times.
8. Status indicators must use the predefined muted red, yellow, green, and blue tokens.
9. Visual density should feel balanced: not cramped, not overly sparse.

If a design decision is unclear, reference `claude_design_guide.md`
before making assumptions.

If the design guide does not cover a situation, extend it in a way
consistent with the established design language.

# API Controller Rules

All `Api::V1` controllers must use RABL views for JSON rendering.

## Requirements

* Never use `render json: @object` for success responses — always delegate to a RABL view.
* Each resource needs `_item.rabl` (partial), `index.rabl`, and `show.rabl` views.
* `index.rabl` uses `collection @objects, root: false, object_root: false`.
* `show.rabl` uses `object @object => nil`.
* Both `index.rabl` and `show.rabl` extend the `_item` partial.
* Error responses (`{ errors: ... }`) may still use `render json:` directly.
* `destroy` actions use `head :no_content` — no RABL needed.
* If RABL is impractical for a specific case, explain why and ask before using an alternative.

---

# Final Directive for Claude

* Follow this schema exactly.
* Do not introduce unnecessary abstraction.
* Do not add microservices.
* Do not add GraphQL.
* Do not over-normalize scope.
* Keep code idiomatic Rails.
* Optimize for clarity and maintainability.
