FactoryGirl.define do
  factory :candidate do
    name Faker::Name.name
    sequence(:email) { |n| "c#{n}#{Faker::Internet.email}" }
    phone Faker::PhoneNumber.cell_phone
    description Faker::Lorem.sentence
  end
end
