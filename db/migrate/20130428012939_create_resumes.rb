class CreateResumes < ActiveRecord::Migration
  def change
    create_table :resumes do |t|
      t.integer :candidate_id
      t.string :name
      t.string :path

      t.timestamps
    end
  end
end
