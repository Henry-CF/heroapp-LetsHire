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


Department.create(Department::DEFAULT_SET)

it = Department.find_by_name 'IT'

long_password = '123456789'

User.new_admin(:email => 'admin@local.com',
               :password => long_password,
               :name => 'System Administrator',
               :department_id => it.id).save