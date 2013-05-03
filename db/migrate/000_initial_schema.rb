class InitialSchema < ActiveRecord::Migration
  def change
    create_table :users do |t|
      ## Database authenticatable
      t.string :email,              :null => false, :default => ""
      t.string :encrypted_password, :null => false, :default => ""

      ## Recoverable
      #t.string   :reset_password_token
      #t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      #t.integer  :sign_in_count, :default => 0
      #t.datetime :current_sign_in_at
      #t.datetime :last_sign_in_at
      #t.string   :current_sign_in_ip
      #t.string   :last_sign_in_ip

      ## Confirmable
      # t.string   :confirmation_token
      # t.datetime :confirmed_at
      # t.datetime :confirmation_sent_at
      # t.string   :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      # t.integer  :failed_attempts, :default => 0 # Only if lock strategy is :failed_attempts
      # t.string   :unlock_token # Only if unlock strategy is :email or :both
      # t.datetime :locked_at

      ## Token authenticatable
      # t.string :authentication_token


      t.string  :name                     # display name
      t.boolean :admin, :null => false, :default => false # whether is system administrator
      t.integer :roles_mask, :default => 1
      t.integer :department_id
      t.string :authentication_token
      t.boolean :deleted, :null => false, :default => false

      t.timestamps
    end

    add_index :users, :email,                :unique => true
    #add_index :users, :reset_password_token, :unique => true
    # add_index :users, :confirmation_token,   :unique => true
    # add_index :users, :unlock_token,         :unique => true
    # add_index :users, :authentication_token, :unique => true

    create_table :candidates do |t|
      t.string :name, :null => false
      t.string :email, :null => false
      t.string :phone
      t.string :source
      t.text   :description
      t.timestamps
    end

    add_index :candidates, :name
    add_index :candidates, :email

    create_table :departments do |t|
      t.string :name, :null => false
      t.string :description
      t.integer :openings_count
    end

    add_index :departments, :name, :unique => true

    create_table :openings do |t|
      t.string :title
      t.string :country
      t.string :province
      t.string :city

      t.references :department
      t.integer :hiring_manager_id
      t.integer :recruiter_id
      t.text :description
      t.integer :status, :default => 0
      t.integer :creator_id
      t.integer :total_no, :default => 1
      t.integer :filled_no, :default => 0

      t.timestamps
    end

    add_index :openings, :hiring_manager_id
    add_index :openings, :recruiter_id
    add_index :openings, :creator_id
    add_index :openings, :department_id

    create_table :opening_participants do |t|
      t.belongs_to :user
      t.belongs_to :opening
    end

    add_index :opening_participants, [:user_id, :opening_id], :unique => true

    create_table :opening_candidates do |t|
      t.belongs_to :opening
      t.belongs_to :candidate
      t.integer :status, :default => 1
      t.boolean :hold
    end

    add_index :opening_candidates, [:opening_id, :candidate_id], :unique => true

    create_table :assessments do |t|
      t.belongs_to :opening_candidate
      t.integer :creator_id
      t.text :comment

      t.timestamps
    end
    add_index :assessments, :opening_candidate_id

    create_table :interviews do |t|
      t.belongs_to :opening_candidate

      t.string :modality,       :null => false
      t.string :title,          :null => false
      t.text :description
      t.string :status, :default => 'scheduled'
      t.float :score
      t.text :assessment
      t.datetime :scheduled_at, :null => false
      t.integer :duration, :default => 30
      t.string :phone
      t.string :location

      t.timestamps
    end

    add_index :interviews, :opening_candidate_id

    create_table :interviewers do |t|
      t.belongs_to :interview
      t.belongs_to :user
      t.timestamps
    end

    add_index :interviewers, [:user_id, :interview_id], :unique => true
  end
end
