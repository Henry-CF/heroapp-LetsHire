class Assessment < ActiveRecord::Base
  attr_accessible :comment, :opening_candidate_id

  belongs_to :opening_candidate
end
