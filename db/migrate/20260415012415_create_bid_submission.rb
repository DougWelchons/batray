class CreateBidSubmission < ActiveRecord::Migration[8.0]
  def change
    create_table :bid_submissions, id: :uuid do |t|
      t.references :project, null: false, foreign_key: true, type: :uuid
      t.references :contractor, null: false, foreign_key: true, type: :uuid
      t.references :contact, null: true, foreign_key: true, type: :uuid
      t.references :user, null: true, foreign_key: true, type: :uuid
      t.string :status, null: false, default: "drafting"
      t.datetime :bid_submitted_at
      t.datetime :bid_due_at
      t.datetime :award_decision_at
      t.decimal :submitted_value, precision: 12, scale: 2
      t.decimal :awarded_value, precision: 12, scale: 2
      t.integer :probability_percent, default: 50
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
