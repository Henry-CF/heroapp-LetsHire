FactoryGirl.define do
  factory :resume do
     candidate_id 1
     resume_name Faker::Name.name
     resume_path Faker::Name.name
  end
end
