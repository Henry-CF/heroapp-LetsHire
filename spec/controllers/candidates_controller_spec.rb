require 'spec_helper'

describe CandidatesController do

  def valid_candidate
    FactoryGirl.attributes_for(:candidate)
  end

  before :each  do
    request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in_as_admin
  end

  describe "GET index" do
    it "assigns all candidates as @candidates" do
      candidate = Candidate.create! valid_candidate
      Candidate.stub(:paginate).and_return([candidate])
      get :index, {}
      assigns(:candidates).should include(candidate)
    end
  end

  describe "GET show" do
    it "assigns the requested candidate as @candidate" do
      candidate = Candidate.create! valid_candidate
      get :show, { :id => candidate.to_param }
      assigns(:candidate).should eq(candidate)
    end
  end

  describe "GET new" do
    it "assigns a new candidate as @candidate" do
      get :new, {}
      assigns(:candidate).should be_a_new(Candidate)
    end
  end

  describe "GET edit" do
    it "assigns the requested candidate as @candidate" do
      candidate = Candidate.create! valid_candidate
      get :edit, { :id => candidate.to_param }
      assigns(:candidate).should eq(candidate)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Candidate" do
        expect do
          post :create, { :candidate => valid_candidate }
        end.to change(Candidate, :count).by(1)
      end

      it "assigns a newly created candidate as @candidate" do
        post :create, { :candidate => valid_candidate }
        assigns(:candidate).should be_a(Candidate)
        assigns(:candidate).should be_persisted
      end

      it "redirects to candidates list" do
        post :create, { :candidate => valid_candidate }
        response.should redirect_to(Candidate.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved candidate as @candidate" do
        Candidate.any_instance.stub(:save).and_return(false)
        post :create, { :candidate => valid_candidate.merge(:email => nil) }
        assigns(:candidate).should be_a_new(Candidate)
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested candidate" do
        candidate = Candidate.create! valid_candidate
        Candidate.any_instance.should_receive(:update_attributes).with({ 'these' => 'params' })
        put :update, { :id => candidate.to_param, :candidate => { 'these' => 'params' } }
      end

      it "assigns the requested candidate as @candidate" do
        candidate = Candidate.create! valid_candidate
        put :update, { :id => candidate.to_param, :candidate => valid_candidate }
        assigns(:candidate).should eq(candidate)
      end
    end

    describe "with invalid params" do
      it "assigns the candidate as @candidate" do
        candidate = Candidate.create! valid_candidate
        Candidate.any_instance.stub(:save).and_return(false)
        put :update, { :id => candidate.to_param, :candidate => {} }
        assigns(:candidate).should eq(candidate)
      end

      it "re-renders the edit template" do
        candidate = Candidate.create! valid_candidate
        Candidate.any_instance.stub(:save).and_return(false)
        put :update, { :id => candidate.to_param, :candidate => {} }
        response.should render_template("edit")
      end
    end
  end

end
