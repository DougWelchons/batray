FactoryBot.define do
  factory :bid_submission do
    project
    contractor
    user
    status               { :drafting }
    bid_due_at           { 14.days.from_now }
    probability_percent  { 50 }
    included_fire_alarm  { [true, false].sample }
    included_low_voltage { [true, false].sample }
    base_scope_description { "Full electrical scope including service entrance, distribution, lighting, and devices." }

    trait :drafting do
      status          { :drafting }
      submitted_value { nil }
      bid_submitted_at { nil }
    end

    trait :submitted do
      status           { :submitted }
      submitted_value  { rand(150_000..3_500_000).round(-3) }
      bid_submitted_at { Faker::Date.between(from: 60.days.ago, to: 7.days.ago) }
    end

    trait :awarded do
      status             { :awarded }
      submitted_value    { rand(150_000..3_500_000).round(-3) }
      bid_submitted_at   { Faker::Date.between(from: 120.days.ago, to: 30.days.ago) }
      award_decision_at  { bid_submitted_at + rand(30..90) }
      awarded_value      { (submitted_value * rand(0.93..1.05)).round(-3) }
      probability_percent { rand(60..90) }
    end

    trait :lost do
      status            { :lost }
      submitted_value   { rand(150_000..3_500_000).round(-3) }
      bid_submitted_at  { Faker::Date.between(from: 120.days.ago, to: 30.days.ago) }
      award_decision_at { bid_submitted_at + rand(30..90) }
      probability_percent { rand(10..45) }
      reason_lost       { ["Price – came in high", "Relationship with incumbent EC", "Scope differences", "Budget cut", "GC self-performed", "Owner canceled project"].sample }
    end

    trait :withdrawn do
      status            { :withdrawn }
      submitted_value   { rand(150_000..3_500_000).round(-3) }
      bid_submitted_at  { Faker::Date.between(from: 120.days.ago, to: 30.days.ago) }
    end

    trait :declined do
      status            { :declined }
      bid_due_at        { Faker::Date.between(from: 60.days.ago, to: 14.days.ago) }
    end
  end
end
