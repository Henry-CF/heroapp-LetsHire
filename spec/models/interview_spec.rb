require 'spec_helper'

describe Interview do
  it 'has a valid interview' do
    @user = FactoryGirl.create(:user)
    @user.should be_valid
    FactoryGirl.build(:interview, :interviewer_ids => [ @user.id]).should be_valid
  end

  it 'requires modality to be valid' do
    result = FactoryGirl.build(:interview, :modality => nil)
    result.should_not be_valid
    result.errors.messages.has_key?(:modality).should be_true
    result = FactoryGirl.build(:interview, :modality => 'Invalid Value')
    result.should_not be_valid
    result.errors.messages.has_key?(:modality).should be_true
  end

  it 'requires title to be present' do
    result = FactoryGirl.build(:interview, :title => nil)
    result.should_not be_valid
    result.errors.messages.has_key?(:title).should be_true
  end

  it 'requires scheduled_at to be present' do
    result = FactoryGirl.build(:interview, :scheduled_at => nil)
    result.should_not be_valid
    result.errors.messages.has_key?(:scheduled_at).should be_true
  end

  it 'requires status to be valid values' do
    result = FactoryGirl.build(:interview, :status => 'Invalid Status')
    result.should_not be_valid
    result.errors.messages.has_key?(:status).should be_true
  end

  describe 'interviewers' do
    let :valid_opening_candidate do
      {
          :candidate_id => Candidate.first.try(:id),
          :opening_id => Opening.first.try(:id)
      }
    end

    def valid_interview
      FactoryGirl.attributes_for(:interview).merge({ :opening_candidate_id => OpeningCandidate.first.try(:id),
                                     :interviewer_ids => [@users[0].id]})
    end

    before :all do
      @users = []
      3.times { @users << create_user(:user) }
      Opening.create! FactoryGirl.attributes_for(:opening).merge({:department_id => @users[0].department_id,
                                                                  :status => 1})
      Candidate.create! FactoryGirl.attributes_for :candidate
      OpeningCandidate.create! valid_opening_candidate
    end

    before :each do
      @interview = Interview.create! valid_interview
    end

    it 'adds interviewers' do
      @interview.update_attributes! :interviewer_ids => @users.map { |user| user.id }
      @interview.reload
      @interview.should have(@users.size).interviewers
    end

    it 'removes interviewers' do
      @interview.update_attributes! :interviewer_ids => @users.map { |user| user.id }
      @interview.reload
      @interview.should have(@users.size).interviewers
      @interview.update_attributes! :interviewer_ids => @users[1..-1].map { |user| user.id }
      @interview.should have(@users.size - 1).interviewers
      @interview.reload
      @interview.should have(@users.size - 1).interviewers
      @interview.interviewers.map { |interviewer| interviewer.user_id }.should_not include(@users[0].id)
    end

    it 'adds and removes interviewers' do
      @interview.update_attributes! :interviewer_ids => @users[1..-1].map { |user| user.id }
      @interview.reload
      @interview.should have(@users.size - 1).interviewers
      @interview.interviewers.map { |interviewer| interviewer.user_id }.should_not include(@users[0].id)
      @interview.update_attributes! :interviewer_ids => @users[0..-2].map { |user| user.id }
      @interview.reload
      @interview.should have(@users.size - 1).interviewers
      @interview.interviewers.map { |interviewer| interviewer.user_id }.should include(@users[0].id)
      @interview.interviewers.map { |interviewer| interviewer.user_id }.should_not include(@users[-1].id)
    end

    it 'create with interviewers' do
      interview = Interview.create! valid_interview.merge(:interviewer_ids => @users.map { |user| user.id })
      interview.should have(@users.size).interviewers
    end
  end
end
