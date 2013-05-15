class Api::V1::InterviewsController < Api::V1::ApiController

  before_filter :verify_current_user, :authenticate_user!

  INTERVAL_MAPPINGS = {
    '1d' => 1.day,
    '1w' => 1.week,
    '1m' => 1.month
  }

  ATTRIBUTE_MAPPINGS = %w[candidate attachment]

  OK = 'success'
  ERROR = 'error'

  def index
    interval = params['interval'] || '1d'
    return invalid_params unless INTERVAL_MAPPINGS.keys.include? interval
    @interviews = Interview.where(:scheduled_at => (Time.now )..(Time.now + INTERVAL_MAPPINGS[interval]))
    render :json => {:ret => OK, :interviews => @interviews}, :status => 200
  end

  def show
    return missing_params unless params['id']

    requested_attrs = ATTRIBUTE_MAPPINGS.select { |key| params[key] == '1' }

    @interview = Interview.find(params['id'])
    @candidate = nil
    @opening = nil
    if requested_attrs.include? 'candidate'
      candidate_id = @interview.opening_candidate.candidate_id
      @candidate = Candidate.find(candidate_id)
      opening_candidate = OpeningCandidate.where(:candidate_id => candidate_id).first
      @opening = Opening.find(opening_candidate.opening_id)
    end
    @attachment = nil

    render :json => {:ret => OK, :interview => @interview, :candidate => @candidate, :attachment => @attachment, :opening => @opening}
  rescue ActiveRecord::RecordNotFound
    return unavailable_instance
  end

  def update
    return missing_params unless params['id']
    return missing_params unless params['interview']
    @interview = Interview.find(params['id'])
    @candidate = nil
    @opening = nil
    if @interview.update_attributes(params['interview'])
      candidate_id = @interview.opening_candidate.candidate
      @candidate = Candidate.find(candidate_id)
      opening_candidate = OpeningCandidate.where(:candidate_id => candidate_id).first
      @opening = Opening.find(opening_candidate.opening_id)
      render :json => {:interview => @interview, :candidate => @candidate, :opening => @opening }, :status => 200
    else
      render :json => {:ret => ERROR, :message => 'internal error'}, :status => 500
    end
  rescue
    return unavailable_instance
  end

  private

  def missing_params
    render :json => {:ret => ERROR, :message => 'missing some key params'}, :status => 401
  end

  def invalid_params
    render :json => {:ret => ERROR, :message => 'invalid params'}, :status => 401
  end

  def unavailable_instance
    render :json => {:ret => ERROR, :message => 'record not found'}, status => 500
  end
end
