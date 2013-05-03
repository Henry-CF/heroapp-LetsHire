class Department < ActiveRecord::Base
  attr_accessible :description, :name
  validates :name, :presence => true, :uniqueness => true
  has_many :openings, :dependent => :destroy

  has_many :users, :dependent => :destroy

  scope :with_at_least_n_openings, ->(n = 1) { where('openings_count >= ?', n)}

end
