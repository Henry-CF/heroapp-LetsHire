require 'spec_helper'
require 'cancan/matchers'

describe User do
  it 'has a valid factory' do
    FactoryGirl.create(:user).should be_valid
  end

  it 'requires email to be present' do
    FactoryGirl.build(:user, :email => nil).should_not be_valid
  end

  it 'requires email to be unique' do
    user = FactoryGirl.create(:user)
    FactoryGirl.build(:user, :email => user.email).should_not be_valid
  end

  it 'requires email to be good format' do
    FactoryGirl.build(:user, :email => 'user@local').should_not be_valid
  end

  it 'creates non-admin user by default' do
    FactoryGirl.build(:user).admin?.should be_false
  end

  it 'creates admin user' do
    User.new_admin.admin?.should be_true
  end

  describe 'abilities' do
    subject { ability }
    let(:ability) { Ability.new(user) }
    let(:user) { nil }


    before :all do
      @hiring_manager1 = create_user(:hiring_manager)
      @recruiter1 = create_user(:recruiter)
      @opening = Opening.create! FactoryGirl.attributes_for(:opening).merge({:department_id => @recruiter1.department_id,
                                                                  :recruiter_id => @recruiter1.id,
                                                                  :creator_id => @hiring_manager1.id,
                                                                  :hiring_manager_id => @hiring_manager1.id})
      @candidate = Candidate.create! FactoryGirl.attributes_for :candidate
      @o_c = OpeningCandidate.create! :opening_id => @opening.id, :candidate_id => @candidate.id
      @users = []
      3.times { @users << create_user(:user) }
      @interview = Interview.create! FactoryGirl.attributes_for(:interview).merge({ :opening_candidate_id => @o_c.id,
                                                                              :user_ids => [@users[0].id, @users[1].id]})
    end


    context 'admin user' do
      let(:user) { User.new_admin }
      it{ should be_able_to(:manage, @interview)}
      it{ should be_able_to(:manage, User.new)}
      it{ should be_able_to(:manage, @opening)}
    end

    context 'normal user' do
      let(:user) { @users[2]}
      it{ should_not be_able_to(:update, @interview)}
      it{ should_not be_able_to(:manage, @interview)}
      it{ should_not be_able_to(:manage, User.new)}
      it{ should_not be_able_to(:manage, Opening)}
    end

    context 'recruiter' do
      let(:user) do
        @recruiter1
      end
      it{ should be_able_to :manage, @interview }
      it{ should be_able_to :manage, @opening }
      it{ should_not be_able_to :manage, User.new }
    end

    context 'hiring_manager' do
      let(:user) do
        @hiring_manager1
      end
      it{ should be_able_to :manage, @interview }
      it{ should be_able_to :manage, @opening }
      it{ should_not be_able_to :manage, User.new }
    end

    context 'interviewer' do
      let(:user)  {@users[0]}
      it{ should_not be_able_to :manage, @interview }
      it{ should be_able_to :update, @interview }
      it{ should_not be_able_to :manage, @opening }
      it{ should_not be_able_to :create, Opening }
      it{ should_not be_able_to :manage, User.new }
    end

    context 'mixed roles' do
      let(:user) do
        user = @users[1]
        user.add_role('hiring_manager')
        user
      end
      it{ should_not be_able_to :manage, @opening }
      it{ should be_able_to :create, Opening }
    end
  end

end
