FactoryBot.define do
  factory :project do
    name                 { Faker::Commerce.unique.product_name + " " + Faker::Address.building_number }
    location             { "San Diego, CA" }
    project_type         { %w[Office Medical Industrial Retail Education Hospitality Data\ Center Multifamily].sample }
    estimated_start_date { Faker::Date.between(from: 3.months.from_now, to: 18.months.from_now) }
    rebid_of             { nil }

    trait :with_bids do
      after(:create) do |project|
        create_list(:bid_submission, rand(1..4), project: project)
      end
    end
  end
end
