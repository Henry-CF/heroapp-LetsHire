class OpeningsController < ApplicationController

  before_filter :require_login, :except => [:index, :show]
  load_and_authorize_resource :except => [:index, :show]

  include ApplicationHelper

  # GET /openings
  # GET /openings.json
  def index
    unless user_signed_in?
      #published openings are returned only
      #TODO: need exclude certain fields from anonymous access, such as 'Hiring Manager'
      @openings = Opening.published.order(sort_column('Opening') + ' ' + sort_direction).paginate(:page => params[:page])
    else
      if params.has_key?(:all)
        @openings = Opening.order(sort_column('Opening') + ' ' + sort_direction).paginate(:page => params[:page])
      elsif params.has_key? :no_candidates
        @openings = Opening.without_candidates.owned_by(current_user.id).order(sort_column('Opening') + ' ' + sort_direction).paginate(:page => params[:page])
      elsif params.has_key? :owned_by_me
        @openings = Opening.owned_by(current_user.id).order(sort_column('Opening') + ' ' + sort_direction).paginate(:page => params[:page])
      else
        if can? :manage, Opening
          @openings = Opening.owned_by(current_user.id).order(sort_column('Opening') + ' ' + sort_direction).paginate(:page => params[:page])
        else
          @openings = current_user.openings
        end
      end
    end

    respond_to do |format|
      format.html  do
        if user_signed_in?
          if params.has_key?(:partial)
            render :partial => "openings/openings_index"
          else
            render "openings/index"
          end
        else
          render "openings/index_anonymous"
        end
      end
      format.json { render json: @openings }
    end
  end

  # GET /openings/1
  # GET /openings/1.json
  def show
    @opening = Opening.find(params[:id])

    respond_to do |format|
      format.html # _assessment.html.slim
      format.json { render json: @opening }
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to openings_url, notice: 'Invalid opening'
  end

  # GET /openings/new
  # GET /openings/new.json
  def new
    @opening = Opening.new(:title => '', :description => description_template)
    @opening.recruiter = current_user if current_user.has_role?(:recruiter)
    @opening.hiring_manager = current_user if current_user.has_role?(:hiring_manager)

    respond_to do |format|
      format.html # edit.html.slim
      format.json { render json: @opening }
    end
  end

  # GET /openings/1/edit
  def edit
    @opening = Opening.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to openings_url, notice: 'Invalid opening'
  end

  # POST /openings
  def create
    @opening = Opening.new(params[:opening])

    @opening.creator = current_user
    if @opening.save
      redirect_to @opening, notice: 'Opening was successfully created.'
    else
      render action: "new"
    end
  end

  # PUT /openings/1
  def update
    @opening = Opening.find(params[:id])

    params[:opening].delete :creator_id

    if @opening.update_attributes(params[:opening])
      redirect_to @opening, notice: 'Opening was successfully updated.'
    else
      render action: "edit"
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to openings_url, notice: 'Invalid opening'
  end

  # POST /openings/1/assign_candidates
  def assign_candidates
    @opening = Opening.find(params[:id])

    params[:candidates] ||= []
    params[:candidates].each do |candidate|
      @opening.opening_candidates.create :candidate_id => candidate
    end
    render :json => { :success => true }
  rescue ActiveRecord::RecordNotFound
    redirect_to openings_url, notice: 'Invalid opening'
  end



  # DELETE /openings/1
  # DELETE /openings/1.json
  def destroy
    @opening = Opening.find(params[:id])
    @opening.destroy

    redirect_to openings_url
  rescue
    redirect_to openings_url, notice: 'Invalid opening'
  end

  def subregion_options
    render :partial => 'utilities/province_select', :locals => { :container => 'opening' }
  end

  def opening_options
    render :partial => 'opening_selection_combox', :locals => {:selected_department_id => params[:selected_department_id] }
  end


  def interviewers_select
    opening = Opening.find(params[:id])
    mode = params[:mode]
    users = (mode == 'all') ? User.all: opening.participants
    render :partial => 'users/user_select', :locals => { :users => users,
                                                         :multiple=> true  }
  rescue
    render :partial => 'users/user_select', :locals => { :users => [] }
  end


  private
  def description_template
        #Fixme: need load from 'setting' page
        <<-END_OF_STRING
About Us

ABC is the world leader in virtualization and cloud infrastructure solutions.
We empower our 400,000 customers by simplifying, automating, and transforming
the way they build, deliver, and consume IT. We are a passionate and innovative
group of people, comprised of thousands of top-notch computer scientists and
software engineers spread across the world.

Job Description
We are seeking ....


Requirements
-	condition 1
-	condition 2

        END_OF_STRING
  end
end
