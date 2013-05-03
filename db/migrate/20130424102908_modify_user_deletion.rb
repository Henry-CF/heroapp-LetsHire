class ModifyUserDeletion < ActiveRecord::Migration
  def up
    remove_column :users, :deleted
    add_column :users, :deleted_at, :datetime
  end

  def down
    remove_column :users, :deleted_at
    add_column :users, :deleted, :boolean
  end
end
