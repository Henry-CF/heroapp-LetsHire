class InterviewsController < AuthorizedController
  def index
    authorize! :read, Interview
    @interviews = Interview.order('scheduled_at ASC')
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

  def new
    authorize! :manage, Interview
    @opening_candidate = OpeningCandidate.find params[:opening_candidate_id] if params[:opening_candidate_id]
    if @opening_candidate.nil?
      return redirect_to interviews_url, :notice  => "Invalid Parameter"
    end
    unless @opening_candidate.in_interview_loop?
      return redirect_to :back, :notice  => "Candidate isn't in interview status for this Job opening"
    end
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
    if params[:interview][:opening_candidate_id].nil?
      redirect_to candidates_path, :notice => "No opening is selected for the candidate"
      return
    end
    @opening_candidate = OpeningCandidate.find params[:interview][:opening_candidate_id]
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
