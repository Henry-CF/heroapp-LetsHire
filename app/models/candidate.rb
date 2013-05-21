class Candidate < ActiveRecord::Base
  attr_accessible :name, :email, :phone, :source, :description

  # valid phone number examples
  # 754-647-0105 x6950
  # (498)479-4559 x2262
  # 775.039.9227 x42375
  # 1-220-680-6355 x59164
  phone_format = Regexp.new("^(\\(\\d+\\)){0,1}(\\d+)[\\d|\\.|-]*(\\sx\\d+){0,1}$")

  validates :name, :presence => true
  validates :email,:presence => true
  validates :email, :email_format => { :message => 'format error' }, :if => :email?
  validates :phone, :presence => true
  validates :phone, :format => { :with => phone_format, :message => 'format error' }, :if => :phone?

  self.per_page = 20

  has_many :opening_candidates, :class_name => 'OpeningCandidate', :dependent => :destroy
  has_many :openings, :class_name => 'Opening', :through => :opening_candidates
  has_one  :resume, :class_name => 'Resume', :dependent => :destroy

  scope :without_opening, where('id NOT IN (SELECT candidate_id FROM opening_candidates)')
  scope :with_opening, joins(:opening_candidates).uniq
  scope :with_interview, joins(:opening_candidates => :interviews).uniq
  scope :without_interview, where('id NOT in ( SELECT DISTINCT "candidates"."id" FROM "candidates" INNER JOIN "opening_candidates" ON "opening_candidates"."candidate_id" = "candidates"."id" INNER JOIN "interviews" ON "interviews"."opening_candidate_id" = "opening_candidates"."id" )')
  scope :with_assessment, joins(:opening_candidates => :assessments).uniq

  def opening(index)
    opening_candidates[index].opening if opening_candidates.size > index
  end

  def interviews_finished_no_assess?
    opening_candidates = OpeningCandidate.where(:candidate_id => id)
    opening_candidates.each do |opening_candidate|
      if opening_candidate.all_interviews_finished?
        assessments = Assessment.where(:opening_candidate_id => opening_candidate.id)
        return true if assessments.empty?
      end
    end
    false
  end

  def self.without_assessment
    candidates = Candidate.with_interview
    candidates.select! do |candidate|
      candidate.interviews_finished_no_assess?
    end
    candidates
  end

end
