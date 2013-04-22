class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :registerable, :recoverable, :rememberable, :trackable, :validatable
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :rememberable, :token_authenticatable

  before_save :ensure_authentication_token

  validates_confirmation_of :password

  # Setup accessible (or protected) attributes for your model
  #attr_accessible :email, :password, :password_confirmation, :remember_me, :name
  attr_accessible :email, :password, :password_confirmation, :name, :department_id, :roles, :remember_me, :authentication_token

  ROLES = %w[interviewer recruiter hiring_manager]

  validates :name,  :presence => true
  validates :email, :presence => true, :uniqueness => true
  validates :email, :email_format => { :message => 'format error'}, :if => :email?


  has_many :openings_to_be_interviewed, :through => :opening_participants
  # NOTE: Currently we are not sure why 'destroy' does not work but 'delete_all' does.
  # From Rails document, the difference between them is that 'destroy' will invokes
  # callback before do database transactions. Let's keep this implementation currently
  # to see if we can get more confidence in the future.
  has_many :opening_participants, :inverse_of => :participant, :dependent => :delete_all

  def admin?
    read_attribute :admin
  end

  def self.name2role(name)
    offset = ROLES.index(name.to_s)
    offset ? 2**offset : 0
  end

  def has_role?(role_name)
    admin? || (roles_mask & User::name2role(role_name) ) != 0
  end

  # The class method used in seed.rb to create the only admin user
  def self.new_admin(options = {})
    user = self.new options
    user.assign_attributes({ :admin => true }, :without_protection => true)
    user
  end

  def self.users_with_role(role_name)
    role_mask = name2role(role_name)
    all.select { |user|  user.admin? || (user.roles_mask & role_mask) != 0}
  end

  def roles=(roles)
    self.roles_mask = (roles & ROLES).map { |r| 2**ROLES.index(r) }.inject(0, :+)
  end

  def roles
    ROLES.reject do |r|
      ((roles_mask || 0) & 2**ROLES.index(r)).zero?
    end
  end

  def roles_string
    roles.join(',')
  end

  def add_role(role)
    self.roles = roles | [role]
  end

  def department_string
    Department.find(self.department_id).name if self.department_id
  end

end
