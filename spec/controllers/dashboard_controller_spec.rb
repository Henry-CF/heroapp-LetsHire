require 'spec_helper'

describe DashboardController do

  def valid_opening
    {
      :title => 'Marketing Manager',
      :department_id => 1,
      :hiring_manager_id => @hiring_manager1.id,
      :recruiter_id => @recruiter1.id,
      :status => 1,
      :creator_id => @hiring_manager1.id
    }
  end

  def valid_candidate
    {
      :name  => Faker::Name.name,
      :email => Faker::Internet.email,
      :phone => Faker::PhoneNumber.phone_number,
      :source => Faker::Lorem.word,
      :description => Faker::Lorem.sentence
    }
  end

  def create_user(role)
    attrs = FactoryGirl.attributes_for(role)
    attrs.delete(:admin)
    attrs.delete(:roles_mask)
    User.create! attrs
  end

  before :each  do
    request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in_as_admin
  end

  describe "GET 'overview'" do
    it "returns http success" do
      get 'overview'
      response.should be_success
    end

    it "assign all candidates as @candidates" do
      candidate = Candidate.create! valid_candidate
      get 'overview'
      assigns(:candidates).should include(candidate)
    end

    it "assign all openings as @openings" do
      @hiring_manager1 = create_user(:hiring_manager)
      @recruiter1 = create_user(:recruiter)
      @user1 = create_user(:user)
      Opening.any_instance.stub(:select_valid_owners_if_active).and_return(true)

      opening = Opening.create! valid_opening
      get 'overview'
      assigns(:openings).should_not include(opening)
    end
  end

end
