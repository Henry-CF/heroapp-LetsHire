class CreateResumes < ActiveRecord::Migration
  def change
    create_table :resumes do |t|
      t.integer :candidate_id
      t.string :resume_name
      t.string :resume_path

      t.timestamps
    end
  end
end
