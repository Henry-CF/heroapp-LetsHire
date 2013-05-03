FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "u#{n}#{Faker::Internet.email}" }
    name Faker::Name.name
    department_id 1
    password (Random.rand * 10000000000).to_i.to_s
  end

  factory :recruiter, :class => :User, :parent => :user do
    sequence(:email) { |n| "r#{n}#{Faker::Internet.email}" }
  end

  factory :hiring_manager, :class => :User, :parent => :user do
    sequence(:email) { |n| "h#{n}#{Faker::Internet.email}" }
  end

  factory :interviewer, :class => :User, :parent => :user do
    sequence(:email) { |n| "i#{n}#{Faker::Internet.email}" }
  end

end

