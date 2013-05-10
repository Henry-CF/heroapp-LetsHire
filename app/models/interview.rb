class Interview < ActiveRecord::Base
  belongs_to :opening_candidate
  has_many :interviewers, :dependent => :destroy
  has_many :users, :through => :interviewers
  has_many :photos, :dependent => :destroy

  accepts_nested_attributes_for :users, :allow_destroy => true, :reject_if => proc { |user| user.empty? }

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

  def editable?
    status != STATUS_CLOSED
  end

end
