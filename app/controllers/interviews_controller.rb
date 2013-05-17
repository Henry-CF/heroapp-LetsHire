class InterviewsController < AuthorizedController
  def index
    authorize! :read, Interview

    if params.has_key? :owned_by_me
      @interviews = Interview.owned_by(current_user.id)
    elsif params.has_key? :interviewed_by_me
      @interviews = Interview.interviewed_by(current_user.id)
    elsif params.has_key? :no_feedback
      @interviews = Interview.where(:assessment => nil)
    else
      @interviews = Interview.all
      unless can? :create, Interview
        @interviews.reject! do |interview|
          not interview.interviewers.any? { |interviewer| interviewer.user_id == current_user.id }
        end
      end
    end
  end

  def show
    @interview = Interview.find params[:id]
    authorize! :read, @interview
    @opening_candidate = @interview.opening_candidate
    @candidate = @interview.opening_candidate.candidate
  end


  def schedule_opening_selection
    authorize! :manage, Interview
    render :action => :schedule_opening_selection, :layout => false
  end


  def edit_multiple
    authorize! :manage, Interview
    @opening_candidate = OpeningCandidate.find(params[:opening_candidate_id]) unless params[:opening_candidate_id].nil?
    if @opening_candidate.nil?
      @opening = Opening.find(params[:opening_id]) unless params[:opening_id].nil?
      return redirect_to :back, :notice  => 'No Candidate to schedule interviews' if @opening.nil?
      @interviews = []
    else
      return redirect_to :back, :notice  => "Candidate isn't in interview status for this Job opening" unless @opening_candidate.in_interview_loop?
      @opening = @opening_candidate.opening
      @interviews = @opening_candidate.interviews
    end
  end

  def update_multiple
    authorize! :manage, Interview

    render :json => { :success => false, :messages => ['Invalid object'] } if params[:interviews].nil?
    new_interviews = params[:interviews]

    return render :json => { :success => true }  if new_interviews[:interviews_attributes].nil?
    @opening_candidate = OpeningCandidate.find new_interviews[:opening_candidate_id] unless new_interviews[:opening_candidate_id].nil?
    if @opening_candidate.nil?
      @opening_candidate = OpeningCandidate.find_by_opening_id_and_candidate_id(new_interviews[:opening_id], new_interviews[:candidate_id])
    end

    new_interviews.delete :opening_candidate_id
    new_interviews.delete :opening_id
    new_interviews.delete :candidate_id
    interview_ids = []
    new_interviews[:interviews_attributes].each { |key, val| interview_ids << val[:id].to_i }
    removed_interview_ids = @opening_candidate.interview_ids - interview_ids
    OpeningCandidate.transaction do
      Interview.delete removed_interview_ids
      if @opening_candidate.update_attributes new_interviews
        render :json => { :success => true }
      else
        puts  @opening_candidate.errors.inspect
        render :json => { :success => false, :messages => @opening_candidate.errors.full_messages, :status => 400 }
      end
    end
  rescue ActiveRecord::RecordNotFound
    render :json => { :success => false, :messages => ['Invalid object'] }
  end

  def schedule_interviews_lineitem
    authorize! :manage, Interview
    interview = Interview.new({ :modality => Interview::MODALITY_PHONE,
                                :duration => 30,
                                :scheduled_at => Time.now.beginning_of_hour + 1.hour,
                                :status => Interview::STATUS_NEW})
    render :partial => 'interviews/schedule_interviews_lineitem', :locals => { :interview => interview }
  end


  def schedule_interviews_collection
    authorize! :manage, Interview
    @opening_candidate = OpeningCandidate.find(params[:opening_candidate_id]) unless params[:opening_candidate_id].nil?
    if @opening_candidate.nil?
      if !params[:opening_id].nil? && !params[:candidate_id].nil?
        @opening_candidate = OpeningCandidate.find_by_opening_id_and_candidate_id(params[:opening_id], params[:candidate_id])
      end
    end
    return :text => '' if @opening_candidate.nil?
    @interviews = @opening_candidate.interviews
    render :partial => 'interviews/schedule_interviews_lineitem', :collection => @interviews, :as => :interview, :layout => false
  end

  def new
    authorize! :manage, Interview
    @opening_candidate = OpeningCandidate.find params[:opening_candidate_id] if params[:opening_candidate_id]
    return redirect_to interviews_url, :notice  => 'No Candidates to schedule interviews' if @opening_candidate.nil?
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
      redirect_to candidates_path, :notice => 'No opening is selected for the candidate'
      return
    end
    if params[:interview].nil?
      redirect_to candidates_path, :notice => 'Invalid parameter'
      return
    end
    @opening_candidate = OpeningCandidate.find params[:opening_candidate_id]
    if @opening_candidate.nil?
      redirect_to candidates_path, :notice => 'No opening is selected for the candidate'
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
      redirect_to @interview, :notice => 'Interview was successfully created'
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
      redirect_to interview_path(@interview), :notice => 'Interview updated'
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
          redirect_to interviews_url, :notice => 'Interview deleted'
        else
          redirect_to :back, :notice => 'Interview deleted'
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
