FactoryGirl.define do
  factory :resume do
     candidate_id 1
     name Faker::Name.name
     path Faker::Name.name
  end
end
