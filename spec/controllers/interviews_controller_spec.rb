require 'spec_helper'

describe InterviewsController do
  def valid_interview(users = nil)
    hash = FactoryGirl.attributes_for(:interview)
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
  end

  describe "Admin user" do
    before :each  do
      sign_in_as_admin
    end

    describe "GET index" do
      it "assigns all interviews as @interviews" do
        interview = Interview.create! valid_interview
        interview.should be_valid
        get :index, {}
        assigns(:interviews).should eq([interview])
      end
    end

    describe "GET show" do
      it "assigns the requested interview as @interview" do
        interview = Interview.create! valid_interview
        get :show, { :id => interview.to_param }
        assigns(:interview).should eq(interview)
      end
    end

    describe "GET new" do
      it "assigns a new interview as @interview" do
        get :new, { :candidate_id => @opening_candidate.candidate_id }
        assigns(:interview).should be_a_new(Interview)
      end
    end

    describe "GET edit" do
      it "assigns the requested interview as @interview" do
        interview = Interview.create! valid_interview
        get :edit, { :id => interview.to_param }
        assigns(:interview).should eq(interview)
      end
    end

    describe "POST create" do
      before :each do
        OpeningCandidate.any_instance.stub(:in_interview_loop?).and_return(true)
      end

      describe "with valid params" do
        it "creates a new Interview" do
          expect do
            post :create, { :interview => valid_interview, :opening_candidate_id => @opening_candidate.id }
          end.to change(Interview, :count).by(1)
        end

        it "assigns a newly created interview as @interview" do
          post :create, { :interview => valid_interview, :opening_candidate_id => @opening_candidate.id }
          assigns(:interview).should be_a(Interview)
          assigns(:interview).should be_persisted
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved interview as @interview" do
          Interview.any_instance.stub(:save).and_return(false)
          post :create, { :opening_candidate_id => @opening_candidate.id }
          assigns(:interview).should be_a_new(Interview)
        end

        it "re-renders the 'edit' template" do
          Interview.any_instance.stub(:save).and_return(false)
          post :create, { :interview => valid_interview, :opening_candidate_id => @opening_candidate.id }
          response.should render_template("edit")
        end
      end

      describe "with interviewers" do
        it "create a new Interview with interviewers" do
          post :create, { :interview => valid_interview(@users) }
          assigns(:interview).should be_a(Interview)
          assigns(:interview).should have(@users.size).interviewers
        end
      end
    end

    describe "PUT update" do
      describe "with valid params" do
        it "updates the requested interview" do
          interview = Interview.create! valid_interview
          Interview.any_instance.should_receive(:update_attributes).with({ 'these' => 'params' })
          put :update, { :id => interview.to_param, :interview => { 'these' => 'params' } }
        end

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
          put :update, { :id => interview.to_param, :interview => { :user_ids => @user_ids } }
          assigns(:interview).should have(@users.size).interviewers
        end

        it "removes interviewers" do
          interview = Interview.create! valid_interview(@users)
          put :update, { :id => interview.to_param, :interview => { :user_ids => @user_ids[1..-1] } }
          assigns(:interview).should have(@users.size - 1).interviewers
          assigns(:interview).interviewers.map { |interviewer| interviewer.user_id }.should_not include(@user_ids[0])
        end

        it "adds and removes interviewers" do
          interview = Interview.create! valid_interview(@users[1..-1])
          put :update, { :id => interview.to_param, :interview => { :user_ids => @user_ids[0..-2] } }
          assigns(:interview).should have(@users.size - 1).interviewers
          assigns(:interview).interviewers.map { |interviewer| interviewer.user_id }.should include(@user_ids[0])
          assigns(:interview).interviewers.map { |interviewer| interviewer.user_id }.should_not include(@user_ids[-1])
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
