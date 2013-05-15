class InterviewsController < AuthorizedController
  def index
    authorize! :read, Interview
    @interviews = Interview.all
    unless can? :create, Interview
      @interviews.reject! do |interview|
        not interview.interviewers.any? { |interviewer| interviewer.user_id == current_user.id }
      end
    end
  end

  def show
    @interview = Interview.find params[:id]
    authorize! :read, @interview
    @opening_candidate = @interview.opening_candidate
    @candidate = @interview.opening_candidate.candidate
  end


  def edit_multiple
    authorize! :manage, Interview
    @opening_candidate = OpeningCandidate.first
    return redirect_to :back, :notice  => "No Candidate to schedule interviews" if @opening_candidate.nil?
    return redirect_to :back, :notice  => "Candidate isn't in interview status for this Job opening" unless @opening_candidate.in_interview_loop?
    #Temporarily fill in fake data
    #@opening_candidate.interviews.create! :scheduled_at => Time.now, :duration => 30, :modality => Interview::MODALITY_ONSITE, :status => Interview::STATUS_CLOSED
    @interviews = @opening_candidate.interviews
  end

  def update_multiple
    authorize! :manage, Interview
    @opening_candidate = OpeningCandidate.find params[:opening_candidate_id]
    params.delete :opening_candidate_id
    params.delete :action
    params.delete :controller
    interview_ids = []
    params[:interviews_attributes].each { |key, val| interview_ids << val[:id].to_i }
    removed_interview_ids = @opening_candidate.interview_ids - interview_ids
    OpeningCandidate.transaction do
      Interview.delete removed_interview_ids
      if @opening_candidate.update_attributes params
        render :json => { :success => true }
      else
        puts  @opening_candidate.errors.inspect
        render :json => { :success => false, :messages => @opening_candidate.errors.full_messages, :status => 400 }
      end
    end
  rescue ActiveRecord::RecordNotFound
    render :json => { :success => false, :messages => ["Invalid object"] }
  end

  def interview_lineitem
    authorize! :manage, Interview
    interview = Interview.new({ :modality => Interview::MODALITY_PHONE,
                                :duration => 30,
                                :scheduled_at => Time.now + 1.hour,
                                :status => Interview::STATUS_NEW})
    render :partial => "interviews/interview_line", :locals => { :interview => interview }
  end

  def new
    authorize! :manage, Interview
    @opening_candidate = OpeningCandidate.find params[:opening_candidate_id] if params[:opening_candidate_id]
    return redirect_to interviews_url, :notice  => "No Candidates to schedule interviews" if @opening_candidate.nil?
    return redirect_to :back, :notice  => "Candidate isn't in interview status for this Job opening" unless @opening_candidate.in_interview_loop?
    @interview = Interview.new
    render :action => 'edit'
  end

  def edit
    @interview = Interview.find params[:id]
    authorize! :update, @interview
    prepare_edit
  end

  def create
    authorize! :manage, Interview
    if params[:opening_candidate_id].nil?
      redirect_to candidates_path, :notice => "No opening is selected for the candidate"
      return
    end
    if params[:interview].nil?
      redirect_to candidates_path, :notice => "Invalid parameter"
      return
    end
    @opening_candidate = OpeningCandidate.find params[:opening_candidate_id]
    if @opening_candidate.nil?
      redirect_to candidates_path, :notice => "No opening is selected for the candidate"
      return
    end
    unless @opening_candidate.in_interview_loop?
      redirect_to @opening.candidate, :notice => "The candidate isn't pending for interview."
      return
    end
    params[:interview].merge! :status => Interview::STATUS_NEW
    params[:interview].delete :opening_id
    @interview = @opening_candidate.interviews.build params[:interview]
    if @interview.save
      update_favorite_interviewers params[:interview][:user_id]
      redirect_to @interview, :notice => "Interview was successfully created"
    else
      prepare_edit
      render :action => 'edit'
    end
  end

  def update
    @interview = Interview.find params[:id]
    authorize! :update, @interview
    @opening_candidate = @interview.opening_candidate
    if @interview.update_attributes(params[:interview])
      update_favorite_interviewers params[:interview][:user_id]
      redirect_to interview_path(@interview), :notice => "Interview updated"
    else
      prepare_edit
      render :action => 'edit'
    end
  end

  # DELETE /interviews/1
  # DELETE /interviews/1.json
  def destroy
    @interview = Interview.find params[:id]
    @candidate = @interview.opening_candidate.candidate
    @interview.destroy

    respond_to do |format|
      format.html do
        if request.referrer == interview_path(@interview)
          redirect_to interviews_url, :notice => "Interview deleted"
        else
          redirect_to :back, :notice => "Interview deleted"
        end
      end
    end
  rescue
    redirect_to interviews_url, notice: 'Invalid interview'
  end

  def update_favorite_interviewers(user_ids)
    user_ids = user_ids.split(',') if user_ids.is_a? String
    if user_ids && user_ids.any?
      opening = @opening_candidate.opening
      user_ids.each do | id |
        op = opening.opening_participants.build
        op.user_id = id
        op.save
      end
    end

  end




  private

  def prepare_edit
    @opening_candidate = @interview.opening_candidate
    @candidate = @opening_candidate.candidate
    @opening = @opening_candidate.opening
  end

end
