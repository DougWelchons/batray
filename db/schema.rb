# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2026_04_02_024259) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "bid_submissions", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.bigint "contractor_id", null: false
    t.bigint "user_id", null: false
    t.integer "status", default: 0, null: false
    t.datetime "bid_submitted_at"
    t.datetime "bid_due_at"
    t.datetime "award_decision_at"
    t.decimal "submitted_value", precision: 12, scale: 2
    t.decimal "awarded_value", precision: 12, scale: 2
    t.integer "probability_percent", default: 50
    t.boolean "included_fire_alarm", default: false
    t.boolean "included_low_voltage", default: false
    t.text "base_scope_description"
    t.string "reason_lost"
    t.text "notes"
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["award_decision_at"], name: "index_bid_submissions_on_award_decision_at"
    t.index ["bid_submitted_at"], name: "index_bid_submissions_on_bid_submitted_at"
    t.index ["contractor_id"], name: "index_bid_submissions_on_contractor_id"
    t.index ["discarded_at"], name: "index_bid_submissions_on_discarded_at"
    t.index ["project_id", "contractor_id"], name: "index_bid_submissions_on_project_id_and_contractor_id", unique: true
    t.index ["project_id"], name: "index_bid_submissions_on_project_id"
    t.index ["status"], name: "index_bid_submissions_on_status"
    t.index ["user_id"], name: "index_bid_submissions_on_user_id"
  end

  create_table "companies", force: :cascade do |t|
    t.string "name", null: false
    t.string "subdomain", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_companies_on_name"
    t.index ["subdomain"], name: "index_companies_on_subdomain", unique: true
  end

  create_table "contractors", force: :cascade do |t|
    t.string "name"
    t.string "contact_name"
    t.string "email"
    t.string "phone"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "company_id", null: false
    t.index ["company_id", "name"], name: "index_contractors_on_company_id_and_name", unique: true
    t.index ["company_id"], name: "index_contractors_on_company_id"
  end

  create_table "projects", force: :cascade do |t|
    t.string "name", null: false
    t.string "location"
    t.string "project_type"
    t.date "estimated_start_date"
    t.integer "rebid_of_id"
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "company_id", null: false
    t.index ["company_id"], name: "index_projects_on_company_id"
    t.index ["discarded_at"], name: "index_projects_on_discarded_at"
    t.index ["rebid_of_id"], name: "index_projects_on_rebid_of_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "company_id", null: false
    t.string "role", default: "estimator"
    t.index ["company_id"], name: "index_users_on_company_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "bid_submissions", "contractors"
  add_foreign_key "bid_submissions", "projects"
  add_foreign_key "bid_submissions", "users"
  add_foreign_key "contractors", "companies"
  add_foreign_key "projects", "companies"
  add_foreign_key "users", "companies"
end
