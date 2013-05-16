require 'filehandler'

class Photo < ActiveRecord::Base
  include FileHandler

  attr_accessible :interview, :interview_id, :description, :name, :path

  belongs_to :interview, :foreign_key => 'interview_id'

  validates :interview_id, :path, :presence => true
end
