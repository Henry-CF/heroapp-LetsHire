class OpeningCandidate < ActiveRecord::Base
  attr_accessible :candidate_id, :opening_id, :status, :interviews_attributes

  belongs_to :candidate
  belongs_to :opening

  has_many :interviews, :dependent => :destroy
  
  has_many :assessments, :dependent => :destroy

  validates :candidate_id, :opening_id, :presence => true

  validates :candidate_id, :uniqueness => { :scope => :opening_id }

  accepts_nested_attributes_for :interviews, :allow_destroy => true, :reject_if => proc { |interview| interview.empty? }


  def status_str
    if status.nil?
      return "interview unscheduled"
    elsif STATUS_STRINGS[status] == OpeningCandidate::INTERVIEW_LOOP
      if interviews.count == 0
        return "interview unscheduled"
      else
        return Interview.overall_status(interviews)
      end
    else
      STATUS_STRINGS[status]
    end
  end

  def next_status_options
    STATUS_LIST
  end


  def in_interview_loop?
    status.nil? || (status == OpeningCandidate::STATUS_LIST[OpeningCandidate::INTERVIEW_LOOP])
  end

  def self.rejected?(user_id)
    records = OpeningCandidate.find(:all, \
                          :conditions=>["opening_candidates.id=interviews.opening_candidate_id and \
                                       interviews.id=interviewers.interview_id and \
                                       interviewers.user_id = #{user_id} and \
                                       opening_candidates.status = 9"], \
                          :include=>[:interviews=>[:interviewers]])
    records
  end

  def self.notconfirmed?(user_id)
    records = OpeningCandidate.find(:all, \
                          :conditions=>["opening_candidates.id=interviews.opening_candidate_id and \
                                       interviews.id=interviewers.interview_id and \
                                       interviewers.user_id = #{user_id} and \
                                       opening_candidates.status = 8"], \
                          :include=>[:interviews=>[:interviewers]])
    records
  end

  def self.accepted?(user_id)
    records = OpeningCandidate.find(:all, \
                          :conditions=>["opening_candidates.id=interviews.opening_candidate_id and \
                                       interviews.id=interviewers.interview_id and \
                                       interviewers.user_id = #{user_id} and \
                                       opening_candidates.status = 10"], \
                          :include=>[:interviews=>[:interviewers]])
    records
  end

  private
  INTERVIEW_LOOP = 'Interview Loop'
  #Don't change order randomly. order matters.
  STATUS_LIST = { INTERVIEW_LOOP => 1,
                  'Fail' => 2,
                  'Quit' => 3,
                  'Offer Pending' => 7,
                  'Offer Sent' => 8,
                  'Offer Declined' => 9,
                  'Offer Accepted' => 10}
  STATUS_STRINGS = STATUS_LIST.invert

end
