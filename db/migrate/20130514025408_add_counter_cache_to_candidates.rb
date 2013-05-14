class AddCounterCacheToCandidates < ActiveRecord::Migration
  def self.up
    add_column :candidates, :opening_candidates_count, :integer, :default => 0
    Candidate.find_each do |candidate|
      candidate.update_attribute(:opening_candidates_count, candidate.opening_candidates.length)
      candidate.save
    end
  end

  def self.down
    remove_column :candidate, :opening_candidates_count
  end
end
