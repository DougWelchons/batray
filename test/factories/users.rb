FactoryBot.define do
  factory :user do
    name     { Faker::Name.name }
    email    { Faker::Internet.unique.email }
    password { "password" }
    password_confirmation { "password" }
    role     { :estimator }

    trait :admin do
      role { :admin }
    end

    trait :estimator do
      role { :estimator }
    end

    trait :viewer do
      role { :viewer }
    end
  end
end
