class RemoveCreatorIdFromAssessments < ActiveRecord::Migration
  def up
    remove_column :assessments, :creator_id
  end

  def down
    add_column :assessments, :creator_id, :integer
  end
end
