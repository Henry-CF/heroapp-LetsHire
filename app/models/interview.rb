class Interview < ActiveRecord::Base

  belongs_to :opening_candidate
  has_many :interviewers, :dependent => :destroy
  has_many :users, :through => :interviewers
  has_many :photos, :dependent => :destroy

  attr_accessible :user_ids

  attr_accessible :opening_candidate_id
  attr_accessible :modality, :scheduled_at, :scheduled_at_iso, :duration, :phone, :location, :description
  attr_accessible :status, :score, :assessment
  attr_accessible :created_at, :updated_at

  # interview status constants
  STATUS_NEW      = 'scheduled'
  STATUS_PROGRESS = 'started'
  STATUS_CLOSED   = 'finished'

  # interview modality constants
  MODALITY_PHONE = 'phone interview'
  MODALITY_ONSITE = 'onsite interview'

  MODALITIES = [MODALITY_PHONE, MODALITY_ONSITE]

  STATUS = [STATUS_NEW, STATUS_PROGRESS, STATUS_CLOSED]

  validates :opening_candidate_id, :presence => true
  validates :modality, :scheduled_at, :presence => true
  validates :modality, :inclusion => MODALITIES
  validates :status, :inclusion => STATUS

  scope :upcoming, lambda { where('scheduled_at > ?', Time.zone.now)}
  scope :during, ->(date) { where('scheduled_at >= ? and scheduled_at <= ?', date.to_time.at_beginning_of_day, date.end_of_day)}
  scope :interviewed_by, ->(user_id) { joins(:interviewers).where('interviewers.user_id = ? ', user_id)}
  #TODO: interview -> opening_candidate -> opening -> owned_by
  scope :owned_by, ->(user_id){ joins(:interviewers).where('interviewers.user_id = ? ', user_id)}

  def self.overall_status(interviews)
    interview_counts = interviews.group(:status).count
    (interview_counts.collect { | key, value | "#{value} #{key} interviews" }).join(',')
  end

  def scheduled_at_iso
    if scheduled_at
      scheduled_at.iso8601
    else
      nil
    end
  end

  def scheduled_at_iso=(val)
    self.scheduled_at = Time.parse val
  rescue
  end

  def interviewers_str
    users.collect { |user| user.name}.join(', ')
  end

  def editable?
    status != STATUS_CLOSED
  end

  def finished?
    status == STATUS_CLOSED
  end

end
