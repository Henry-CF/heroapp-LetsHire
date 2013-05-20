require 'spec_helper'

describe Candidate do
  it 'has a valid factory' do
    FactoryGirl.create(:candidate).should be_valid
  end

  it 'requires name to be present' do
    FactoryGirl.build(:candidate, :name => nil).should_not be_valid
  end

  it 'requires email to be present' do
    FactoryGirl.build(:candidate, :email => nil).should_not be_valid
  end

  it 'requires email address format to be valid' do
    FactoryGirl.build(:candidate, :email => 'xxx').should_not be_valid
  end

  it 'requires phone number format to be valid' do
    FactoryGirl.build(:candidate, :phone => '123x43y87').should_not be_valid
  end

  it 'status should be inactive after call mark_inactive' do
    candidate = FactoryGirl.build(:candidate)
    candidate.mark_inactive
    candidate.status.should be_equal(1)
  end
end
