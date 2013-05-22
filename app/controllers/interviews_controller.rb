class InterviewsController < AuthorizedController
  include InterviewsHelper
  def index
    authorize! :read, Interview

    if params.has_key? :owned_by_me
      @interviews = Interview.owned_by(current_user.id)
    elsif params.has_key? :interviewed_by_me
      @interviews = Interview.interviewed_by(current_user.id)
    elsif params.has_key? :interviewed_by_me_today
      @interviews = Interview.interviewed_by(current_user.id).during(Time.zone.now)
    elsif params.has_key? :no_feedback
      @interviews = Interview.where(:assessment => nil)
    elsif params.has_key? :all
      @interviews = Interview.all
    else
      # show interviews interviewed by me by default
      @interviews = Interview.interviewed_by(current_user.id)
    end

    if params.has_key? :partial
      render :partial => 'interviews/interviews_index', :locals => {:opening_candidate => nil}
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
    OpeningCandidate.transaction do
      if @opening_candidate.update_attributes new_interviews
        user_ids = []
        new_interviews[:interviews_attributes].each do |key, val|
          user_ids.concat val[:user_ids] if val[:user_ids].is_a?(Array)
        end
        update_favorite_interviewers user_ids
        render :json => { :success => true }
      else
        puts  @opening_candidate.errors.inspect
        render :json => { :success => false, :messages => @opening_candidate.errors.full_messages, :status => 400 }
      end
    end
  rescue ActiveRecord::RecordNotFound
    render :json => { :success => false, :messages => ['Invalid object'] }
  end

  def schedule_add
    authorize! :manage, Interview

    parse_parent
    return render :text => '' if @opening_candidate.nil? || !@opening_candidate.in_interview_loop?
    interview = Interview.new({ :modality => Interview::MODALITY_PHONE,
                                :opening_candidate_id => @opening_candidate.id,
                                :duration => 30,
                                :scheduled_at => Time.now.beginning_of_hour + 1.hour,
                                :status => Interview::STATUS_NEW})

    render :partial => 'interviews/schedule_interviews_lineitem', :locals => { :interview => interview }
  end


  def schedule_reload
    authorize! :manage, Interview

    parse_parent

    return :text => '' if @opening_candidate.nil?
    @interviews = @opening_candidate.interviews

    render :partial => 'schedule_reload', :layout => false
  end

  def edit
    @interview = Interview.find params[:id]
    authorize! :update, @interview
    prepare_edit
    unless is_interviewer? @interview.interviewers
      redirect_to :back, :notice => 'Not an interviewer'
    end
  end


  def update
    @interview = Interview.find params[:id]
    authorize! :update, @interview
    unless params[:interview][:assessment].nil?
      unless is_interviewer? @interview.interviewers
        return render :action => :edit, :notice => 'Not an interviewer'
      else
        @interview.assessment = params[:interview][:assessment]
      end
    end
    @interview.status = params[:interview][:status] unless params[:interview][:status].nil?

    if @interview.save
      redirect_to interview_path(@interview), :notice => 'Interview is updated successfully'
    else
      prepare_edit
      render :action => :edit
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
    user_ids ||= []
    if user_ids.any?
      opening = @opening_candidate.opening
      user_ids.each do |id|
        if id.to_i > 0
          op = opening.opening_participants.build
          op.user_id = id
          op.save
        end
      end
    end
  end

  private
  def parse_parent
    @opening_candidate = OpeningCandidate.find(params[:opening_candidate_id]) unless params[:opening_candidate_id].nil?
    if @opening_candidate.nil?
      if !params[:opening_id].nil? && !params[:candidate_id].nil?
        @opening_candidate = OpeningCandidate.find_by_opening_id_and_candidate_id(params[:opening_id], params[:candidate_id])
      end
    end
  end



  def prepare_edit
    @opening_candidate = @interview.opening_candidate
    @candidate = @opening_candidate.candidate
    @opening = @opening_candidate.opening
  end

end
