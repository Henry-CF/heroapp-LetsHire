class Interview < ActiveRecord::Base
  belongs_to :opening_candidate
  has_many :interviewers, :dependent => :destroy
  has_many :users, :through => :interviewers

  accepts_nested_attributes_for :interviewers, :allow_destroy => true, :reject_if => proc { |interviewers| interviewers.empty? }

  attr_accessible :opening_candidate, :opening_candidate_id
  attr_accessible :interviewer_ids
  attr_accessible :title, :modality, :scheduled_at, :scheduled_at_iso, :duration, :phone, :location, :description
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
  validates :modality, :title, :scheduled_at, :presence => true
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

  def scheduled_at_iso=(val)
    self.scheduled_at = Time.parse val
  rescue
  end

  def interviewer_ids=(ids)
    ids.map! { |id| id.to_i }
    removes = []
    interviewers.each do |interviewer|
      removes << interviewer if ids.delete(interviewer.user_id).nil?
    end
    transaction do
      removes.each do |interviewer|
        interviewers.delete interviewer
      end
      ids.each do |id|
        interviewers << Interviewer.new(:user_id => id)
      end
    end
  end
end
