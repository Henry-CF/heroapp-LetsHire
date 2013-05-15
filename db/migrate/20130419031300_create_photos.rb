class CreatePhotos < ActiveRecord::Migration
  def change
    create_table :photos do |t|
      t.integer :interview_id
      t.string  :photo_name
      t.string  :photo_path
      t.text    :description

      t.timestamps
    end
  end
end
