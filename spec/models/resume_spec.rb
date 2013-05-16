require 'spec_helper'

describe Resume do
  it 'should has a valid resume' do
    FactoryGirl.create(:resume).should be_valid
  end

  it 'requires candidate_id to be present and unique' do
    FactoryGirl.build(:resume, :candidate_id => nil).should_not be_valid
    resume = FactoryGirl.create(:resume)
    FactoryGirl.build(:resume, :candidate_id => resume.candidate_id).should_not be_valid
  end

  it 'requires resume_name to be present' do
    FactoryGirl.build(:resume, :name => nil).should_not be_valid
  end

  it 'requires resume_path to be present' do
    FactoryGirl.build(:resume, :path => nil).should_not be_valid
  end
end
