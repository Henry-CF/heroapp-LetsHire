require 'filehandler'

class Resume < ActiveRecord::Base
  include FileHandler

  attr_accessible :candidate, :candidate_id, :name, :path

  belongs_to :candidate, :foreign_key => 'candidate_id'

  validates :candidate_id, :name, :path, :presence => true
  validates :candidate_id, :uniqueness => true
end
