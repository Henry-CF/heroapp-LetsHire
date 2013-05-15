class RemoveTitleFromInterview < ActiveRecord::Migration
  def up
    remove_column :interviews, :title

  end

  def down
    add_column :interviews, :title, :string
  end
end
