class OpeningCandidate < ActiveRecord::Base
  attr_accessible :candidate_id, :opening_id, :status, :interviews_attributes

  belongs_to :candidate, :counter_cache => true
  belongs_to :opening, :counter_cache => true

  has_many :interviews, :dependent => :destroy

  has_one :assessment, :dependent => :destroy

  validates :candidate_id, :opening_id, :presence => true

  validates :candidate_id, :uniqueness => { :scope => :opening_id }

  accepts_nested_attributes_for :interviews, :allow_destroy => true, :reject_if => proc { |interview| interview.empty? }

  def overall_status_str
    if status.nil?
      return 'interview unscheduled'
    elsif STATUS_STRINGS[status] == OpeningCandidate::INTERVIEW_LOOP
      if interviews.count == 0
        return 'interview unscheduled'
      else
        return Interview.overall_status(interviews)
      end
    else
      STATUS_STRINGS[status]
    end
  end

  def status_str
    if status.nil?
      return 'interview unscheduled'
    else
      STATUS_STRINGS[status]
    end
  end

  def next_status_options
    STATUS_LIST
  end

  def all_interviews_finished?
    return false if interviews.empty?
    interviews.each do |interview|
      return false unless interview.finished?
    end
    true
  end

  def in_interview_loop?
    status.nil? || (status == OpeningCandidate::STATUS_LIST[OpeningCandidate::INTERVIEW_LOOP])
  end

  def quit?
    status == OpeningCandidate::STATUS_LIST[OpeningCandidate::INTERVIEW_QUIT]
  end

  def closed?
    status == OpeningCandidate::STATUS_LIST[OpeningCandidate::INTERVIEW_CLOSED]
  end

  def fail_job_application(reason='')
    update_attributes(:status => OpeningCandidate::STATUS_LIST[OpeningCandidate::INTERVIEW_FAIL], :assessment => reason)
  end

  def quit_job_application
    update_attributes(:status => OpeningCandidate::STATUS_LIST[OpeningCandidate::INTERVIEW_QUIT])
  end

  def close_job_application
    update_attributes(:status => OpeningCandidate::STATUS_LIST[OpeningCandidate::INTERVIEW_CLOSED])
  end

  def reopen_job_application
    update_attributes(:status => OpeningCandidate::STATUS_LIST[OpeningCandidate::INTERVIEW_LOOP])
  end

  # find all 'rejected' records belong to recruiter user
  def self.rejected?(user_id)
    records = OpeningCandidate.find(:all, \
                          :conditions=>["opening_candidates.opening_id=openings.id and \
                                       openings.recruiter_id = users.id and \
                                       users.id = #{user_id} and \
                                       opening_candidates.status = #{STATUS_LIST['Offer Declined']}"], \
                          :include=>[:opening=>[:recruiter]])
    records
  end

  # find all 'notconfirmed' records belong to recruiter user
  def self.notconfirmed?(user_id)
    records = OpeningCandidate.find(:all, \
                          :conditions=>["opening_candidates.opening_id=openings.id and \
                                       openings.recruiter_id = users.id and \
                                       users.id = #{user_id} and \
                                       opening_candidates.status = #{STATUS_LIST['Offer Pending']}"], \
                          :include=>[:opening=>[:recruiter]])
    records
  end

  # find all 'accepted' records belong to recruiter user
  def self.accepted?(user_id)
    records = OpeningCandidate.find(:all, \
                          :conditions=>["opening_candidates.opening_id=openings.id and \
                                       openings.recruiter_id = users.id and \
                                       users.id = #{user_id} and \
                                       opening_candidates.status = #{STATUS_LIST['Offer Accepted']}"], \
                          :include=>[:opening=>[:recruiter]])
    records
  end

  private
  INTERVIEW_LOOP = 'Interview Loop'
  INTERVIEW_FAIL = 'Fail'
  INTERVIEW_QUIT = 'Quit'
  INTERVIEW_CLOSED = 'Closed'
  #Don't change order randomly. order matters.
  STATUS_LIST = { INTERVIEW_LOOP => 1,
                  'Fail' => 2,
                  'Quit' => 3,   # candidate quit
                  'Closed' => 4, # opening closed
                  'Offer Pending' => 7,
                  'Offer Sent' => 8,
                  'Offer Declined' => 9,
                  'Offer Accepted' => 10}
  STATUS_STRINGS = STATUS_LIST.invert

end
