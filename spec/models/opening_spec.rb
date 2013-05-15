require 'spec_helper'

describe Opening do
  before :all do
    @hiring_manager1 = create_user(:hiring_manager)
  end

  it 'has a valid factory' do
    Opening.create!(FactoryGirl.attributes_for(:opening).merge({:department_id => @hiring_manager1.department_id,
                                                                :creator_id => @hiring_manager1.id,
                                                                :hiring_manager_id => @hiring_manager1.id})).should be_valid
  end

  it 'requires a title' do
    FactoryGirl.build(:opening, :title => nil).should_not be_valid
  end

  it 'requires a valid hiring manager if set' do
    opening = FactoryGirl.build(:opening, :hiring_manager_id => 0x7fff)
    opening.should_not be_valid
    opening.errors[:hiring_manager_id].join("; ").should == "isn't a hiring manager"
  end

  it 'requires a valid recruiter if set' do
    opening = FactoryGirl.build(:opening, :recruiter_id => 0x7fff)
    opening.should_not be_valid
    opening.errors[:recruiter_id].join("; ").should == "isn't a recruiter"
  end

end
