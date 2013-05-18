require 'spec_helper'

describe InterviewsController do
  def valid_interview(users = nil)
    hash = FactoryGirl.attributes_for(:interview).merge(:opening_candidate_id => @opening_candidate.id)
    hash = hash.merge :user_ids => users.map { |user| user.id } if users.is_a?(Array)
    hash
  end

  before :all do
    @hiring_manager1 = create_user(:hiring_manager)
    @recruiter1 = create_user(:recruiter)

    @users = []
    3.times { @users << create_user(:user) }
    @opening = Opening.create! FactoryGirl.attributes_for(:opening).merge(:creator_id => @users[0].id,
                                                                          :hiring_manager_id => @hiring_manager1.id,
                                                                          :department_id => @hiring_manager1.department_id,)
    @candidate = Candidate.create! FactoryGirl.attributes_for(:candidate)
    @candidate.should be_valid
    @opening_candidate = OpeningCandidate.create!(:opening_id => @opening.id, :candidate_id => @candidate.id)
    @opening_candidate.should be_valid
    @user_ids = @users.map { |user| user.id }
  end

  before :each  do
    request.env["devise.mapping"] = Devise.mappings[:user]
    request.env['HTTP_REFERER'] = interviews_url
  end

  describe "Admin user" do
    before :each  do
      sign_in_as_admin
    end

    describe "GET show" do
      it "assigns the requested interview as @interview" do
        interview = Interview.create! valid_interview
        get :show, { :id => interview.to_param }
        assigns(:interview).should eq(interview)
      end
    end

    describe "GET schedule interviews" do
      xit "schedule multiple interviews" do
      end
    end

    describe "PUT update" do
      describe "with valid params" do
        it "assigns the requested interview as @interview" do
          interview = Interview.create! valid_interview
          put :update, { :id => interview.to_param, :interview => valid_interview }
          assigns(:interview).should eq(interview)
        end
      end

      describe "with invalid params" do
        it "assigns the interview as @interview" do
          interview = Interview.create! valid_interview
          Interview.any_instance.stub(:save).and_return(false)
          put :update, { :id => interview.to_param, :interview => {} }
          assigns(:interview).should eq(interview)
        end

        it "re-renders the 'edit' template" do
          interview = Interview.create! valid_interview
          Interview.any_instance.stub(:save).and_return(false)
          put :update, { :id => interview.to_param, :interview => {} }
          response.should render_template("edit")
        end
      end

      describe "with interviewers" do
        it "adds interviewers" do
          interview = Interview.create! valid_interview
          post :update_multiple, :interviews => { :opening_candidate_id => @opening_candidate.id,
                                                  :interviews_attributes => {'0' => { :id => interview.to_param, :user_ids => @user_ids }}}
          interview.reload
          interview.should have(@users.size).interviewers
        end

        it "removes interviewers" do
          interview = Interview.create! valid_interview(@users)
          post :update_multiple, :interviews => { :opening_candidate_id => @opening_candidate.id,
                                                  :interviews_attributes => {'0' => { :id => interview.to_param, :user_ids => @user_ids[1..-1] }}}
          interview.reload
          interview.should have(@users.size - 1).interviewers
          interview.interviewers.map { |interviewer| interviewer.user_id }.should_not include(@user_ids[0])
        end

        it "adds and removes interviewers" do
          interview = Interview.create! valid_interview(@users[1..-1])
          post :update_multiple, :interviews => { :opening_candidate_id => @opening_candidate.id,
                                                  :interviews_attributes => {'0' => { :id => interview.to_param, :user_ids => @user_ids[0..-2] }}}
          interview.reload
          interview.should have(@users.size - 1).interviewers
          interview.interviewers.map { |interviewer| interviewer.user_id }.should include(@user_ids[0])
          interview.interviewers.map { |interviewer| interviewer.user_id }.should_not include(@user_ids[-1])
        end
      end
    end
  end

  describe "Interviewer" do
    before :each  do
      sign_in @users[0]
    end

    describe "GET index" do
      it "assigns all interviews as @interviews" do
        interview = Interview.create! valid_interview(@users)
        get :index, {}
        assigns(:interviews).should eq([interview])
      end
    end
  end
end
