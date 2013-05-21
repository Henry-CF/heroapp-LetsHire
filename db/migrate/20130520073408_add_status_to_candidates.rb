class AddStatusToCandidates < ActiveRecord::Migration
  def change
    add_column :candidates, :status, :integer, :default => 0
  end
end
