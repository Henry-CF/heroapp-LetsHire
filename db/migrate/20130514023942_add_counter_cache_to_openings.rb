class AddCounterCacheToOpenings < ActiveRecord::Migration
  def self.up
    add_column :openings, :opening_candidates_count, :integer, :default => 0
    Opening.find_each do |opening|
      Opening.reset_counters opening.id, :opening_candidates
    end
  end

  def self.down
    remove_column :openings, :opening_candidates_count
  end
end
