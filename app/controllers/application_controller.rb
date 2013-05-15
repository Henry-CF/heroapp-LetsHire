class ApplicationController < ActionController::Base
  protect_from_forgery

  REQUIRE_LOGIN = 'You must be logged in to access this section'
  REQUIRE_ADMIN = 'You must be admin to access this section'
  NO_PERMISSION = 'You do not have permission to access this section'

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path, :notice => NO_PERMISSION
  end

  # Hack for db_seed because 'vmc console' is slow
  def db_seed
    return render :text => 'DB is initialized already' if User.count > 0 || Department.count > 0
    long_password = '123456789'

    Department.create(Department::DEFAULT_SET)
    it = Department.find_by_name 'IT'
    User.new_admin(:email => 'admin@local.com',
                   :password => long_password,
                   :name => 'System Administrator',
                   :department_id => it.id).save

    redirect_to new_user_session_path, :notice => 'DB initialized successfully'
  end

  private

  def require_login
    unless user_signed_in?
      redirect_to new_user_session_path, :notice => REQUIRE_LOGIN
    end
  end

  def require_admin
    unless current_user and current_user.admin?
      redirect_to root_path, :notice => REQUIRE_ADMIN
    end
  end

  def after_sign_in_path_for(resource)
    root_path
  end
end
