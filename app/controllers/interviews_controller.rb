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
    @candidate = @interview.opening_candidate.candidate
    @opening_candidate = @interview.opening_candidate
  end

  def new
    authorize! :manage, Interview
    @candidate = Candidate.find params[:candidate_id]
    @opening_candidate = OpeningCandidate.find params[:opening_candidate_id] if params[:opening_candidate_id]
    load_openings
    @interview = Interview.new
    @interview.errors.add(:opening_candidate_id, "isn't in interview status") if @opening_candidates.size == 0
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
    @interview = @opening_candidate.interviews.build params[:interview]
    if @interview.save
      redirect_to @interview, :notice => "Interview was successfully created"
    else
      prepare_edit
      render :action => 'edit'
    end
  end

  def update
    @interview = Interview.find params[:id]
    authorize! :update, @interview
    if @interview.update_attributes(params[:interview])
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

  private

  def prepare_edit
    @opening_candidate = @interview.opening_candidate
    @candidate = @opening_candidate.candidate
    load_openings unless @candidate.nil?
  end

  def load_openings
    @opening_candidates = @candidate.opening_candidates.select { |item| item.in_interview_loop? }
    interviewers_hash = {}
    @opening_candidates.each do |opening_candidate|
      opening = opening_candidate.opening
      if can? :manage, opening
        opening_interviewers = []
        opening.participants.each do |participant|
          opening_interviewers << {
              id: participant.id,
              name: participant.name,
              email: participant.email
          }
        end
        interviewers_hash[opening_candidate.id] = opening_interviewers
      end
    end
    @interviewers_json = interviewers_hash.to_json
  end
end
