class CreateBidSubmissions < ActiveRecord::Migration[8.2]
  def change
    create_table :bid_submissions do |t|
      t.references :project, null: false, foreign_key: true
      t.references :contractor, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :status, null: false, default: 0
      t.datetime :bid_submitted_at
      t.datetime :bid_due_at
      t.datetime :award_decision_at
      t.decimal :submitted_value, precision: 12, scale: 2
      t.decimal :awarded_value, precision: 12, scale: 2
      t.integer :probability_percent, default: 50
      t.boolean :included_fire_alarm, default: false
      t.boolean :included_low_voltage, default: false
      t.text :base_scope_description
      t.string :reason_lost
      t.text :notes
      t.datetime :discarded_at

      t.timestamps
    end

    add_index :bid_submissions, :status
    add_index :bid_submissions, :bid_submitted_at
    add_index :bid_submissions, :award_decision_at
    add_index :bid_submissions, :discarded_at
    add_index :bid_submissions, [ :project_id, :contractor_id ], unique: true
  end
end
