require 'spec_helper'

describe Api::V1::InterviewsController do

  let :valid_candidate do
    {
      :name => Faker::Name.name,
      :email => Faker::Internet.email,
      :phone => Faker::PhoneNumber.phone_number
    }
  end

  let :valid_opening_candidate do
    {
      :candidate_id => @candidate.id,
      :opening_id => 1
    }
  end

  def valid_interview(users = nil)
    hash = FactoryGirl.attributes_for(:interview).merge({
              :opening_candidate_id => @opening.id,
              :scheduled_at => (DateTime.now + 1.hour).to_s
          })
    hash = hash.merge :user_ids => users.map { |user| user.id } if users.is_a?(Array)
    hash
  end

  before :all do
    @hiring_manager1 = create_user(:hiring_manager)
    @users = []
    user_password = '12345678'
    3.times do
      @users << User.create!(:name => Faker::Name.name, :email => Faker::Internet.email + UUIDTools::UUID.random_create.to_s, :password => user_password)
    end
    @candidate = Candidate.create! valid_candidate
    @opening = OpeningCandidate.create! valid_opening_candidate
    @user_ids = @users.map { |user| user.id }
  end

  before :each  do
    request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe 'RESTful API' do

    before :each do
      user = sign_in_as_admin
      @token = user[:authentication_token]
    end

    it 'can fetch all interviews in one interval' do
      interview = Interview.create! valid_interview(@users)

      get :index, :auth_token => @token
      assigns(:interviews).should eq([interview])

      get :index, :auth_token => @token, :interval => '1w'
      assigns(:interviews).should eq([interview])

      get :index, :auth_token => @token, :interval => '1m'
      assigns(:interviews).should eq([interview])
    end

    it 'can not fetch any interviews if interval params invalid' do
      interview = Interview.create! valid_interview(@users)
      get :index, :auth_token => @token, :interval => 'other'
      assigns(:interviews).should be_nil
    end

    it 'can fetch specific interview details' do
      interview = Interview.create! valid_interview(@users)

      get :show, :auth_token => @token, :id => interview.id, :candidate => '0'
      assigns(:interview).should be_a(Interview)
      assigns(:candidate).should be_nil

      get :show, :auth_token => @token, :id => interview.id, :candidate => '1'
      assigns(:interview).should be_a(Interview)
      assigns(:candidate).should be_a(Candidate)
    end

    it 'can update specific interview' do
      interview = Interview.create! valid_interview(@users)
      interview.status = Interview::STATUS_CLOSED
      post :update, :auth_token => @token, :id => interview.id, :interview => {:status => Interview::STATUS_CLOSED }
      assigns(:interview).should eq(interview)
    end

  end
end
