# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
Opening.delete_all
Candidate.delete_all
User.delete_all
Department.delete_all


Department.create([ { name: 'Administration', description: 'Administration & Facility Department'},
                    { name: 'Facility', description: 'Facility'},
                    { name: 'Finance', description: 'Finanace'},
                    { name: 'HR', description: 'Human Resource'},
                    { name: 'Marketing', description: 'Marketing'},
                    { name: 'R&D', description: 'Rearch and Development'},
                  ])


it = Department.create({ name: 'IT', description: 'IT'})

long_password = '123456789'

User.new_admin(:email => 'admin@local.com',
               :password => long_password,
               :name => 'System Administrator',
               :department_id => it.id).save

# For test convinience temporarily
user = User.new({ :email => 'i1@local.com', :password => long_password, :name => 'interviewer1', :department_id => 4 })
user.roles = ['interviewer']
user.save
user = User.new({ :email => 'r1@local.com', :password => long_password, :name => 'recruiter1', :department_id => 4 })
user.roles = ['recruiter']
user.save
user = User.new({ :email => 'h1@local.com', :password => long_password, :name => 'recruiting hiring manager 1', :department_id => 4 })
user.roles = ['hiring_manager','recruiter']
user.save


Candidate.create({ :name => 'Jason', :email => 'jason@local.com', :phone => '021-111', :source => 'internal referral', :description => 'xxx' })
Candidate.create({ :name => 'Tom', :email => 'tom@local.com', :phone => '021-222', :source => 'internal referral', :description => 'xxx' })
