class AddCounterCacheToOpenings < ActiveRecord::Migration
  def self.up
    add_column :openings, :opening_candidates_count, :integer, :default => 0
    Opening.find_each do |opening|
      opening.update_attribute(:opening_candidates_count, opening.opening_candidates.length)
      opening.save
    end
  end

  def self.down
    remove_column :openings, :opening_candidates_count
  end
end
