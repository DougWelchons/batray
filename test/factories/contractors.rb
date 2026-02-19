FactoryBot.define do
  factory :contractor do
    name         { Faker::Company.unique.name }
    contact_name { Faker::Name.name }
    email        { Faker::Internet.email }
    phone        { Faker::PhoneNumber.phone_number }
    notes        { nil }
  end
end
