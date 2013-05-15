class Interview < ActiveRecord::Base
  belongs_to :opening_candidate
  has_many :interviewers, :dependent => :destroy
  has_many :users, :through => :interviewers
  has_many :photos, :dependent => :destroy

  accepts_nested_attributes_for :interviewers, :allow_destroy => true, :reject_if => proc { |interviewers| interviewers.empty? }

  attr_accessible :user_id, :user_ids

  attr_accessible :opening_candidate, :opening_candidate_id
  attr_accessible :modality, :scheduled_at, :scheduled_at_iso, :duration, :phone, :location, :description
  attr_accessible :status, :score, :assessment
  attr_accessible :created_at, :updated_at

  # interview status constants
  STATUS_NEW      = "scheduled"
  STATUS_PROGRESS = "started"
  STATUS_CLOSED   = "finished"

  # interview modality constants
  MODALITY_PHONE = "phone interview"
  MODALITY_ONSITE = "onsite interview"

  MODALITIES = [MODALITY_PHONE, MODALITY_ONSITE]

  STATUS = [STATUS_NEW, STATUS_PROGRESS, STATUS_CLOSED]

  validates :opening_candidate_id, :presence => true
  validates :modality, :scheduled_at, :presence => true
  validates :modality, :inclusion => MODALITIES
  validates :status, :inclusion => STATUS

  scope :upcoming, where('scheduled_at > ?', Time.zone.now)

  def self.overall_status(interviews)
    interview_counts = interviews.group(:status).count
    (interview_counts.collect { | key, value | "#{value} #{key} interviews" }).join(",")
  end

  def scheduled_at_iso
    if scheduled_at
      scheduled_at.iso8601
    else
      nil
    end
  end

  def user_id
    user_ids.try(:first)
  end

  def user_id=(id)
    self.user_ids = [id]
  end

  def scheduled_at_iso=(val)
    self.scheduled_at = Time.parse val
  rescue
  end

  def interviewed_by?(user_id)
    flag = false
    interviewers.each do |interviewer|
       flag = true if interviewer.user_id == user_id
    end
    flag
  end

  def self.interviewed_by_me(user_id)
    interviews = Interview.upcoming
    my_interviews = interviews.inject([]) do |ret, interview|
      ret << interview if interview.interviewed_by?(user_id)
    end
    my_interviews
  end

  def self.owned_by(user_id)
    interviews = Interview.upcoming
    owned_interviews = interviews.inject([]) do |ret, interview|
      ret << interview if interview.user_ids.include?(user_id)
    end
    owned_interviews
  end

end
