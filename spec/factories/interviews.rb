FactoryGirl.define do
  factory :interview do
    opening_candidate_id 1
    modality     "phone interview"
    description  Faker::Lorem.paragraph
    status       "scheduled"
    score        9.2
    assessment   Faker::Lorem.paragraph
    scheduled_at DateTime.now
    duration     30
    phone        Faker::PhoneNumber.phone_number
    location     Faker::Address.state
  end
end
