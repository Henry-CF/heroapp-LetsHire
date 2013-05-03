class UsersController < AuthenticatedController

  before_filter :require_admin, :except => [:index_for_tokens]

  def index
    @users = User.paginate(:page => params[:page], :per_page => 20)
  end

  def index_for_tokens
    unless user_signed_in?
      redirect_to new_user_session_path, :notice => REQUIRE_LOGIN
    end
    if params[:all]
      @participants = User.select("id, name, email").where("name like ?", "%#{params[:q]}%")
    else
      @participants = User.active.select("id, name, email").where("name like ?", "%#{params[:q]}%")
    end
    respond_to do |format|
      format.json { render :json => @participants.map(&:attributes) }
    end
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      redirect_to users_url
    else
      render :action => 'new'
    end
  end

  def new
    @user = User.new
  end

  def show
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to users_url, notice: 'Invalid user'
  end

  def update
    @user = User.find(params[:id])

    # required for settings form to submit when password is left blank
    if params[:user][:password].blank?
      params[:user].delete("password")
      params[:user].delete("password_confirmation")
    end

    params[:user].delete("deleted_at")

    if @user.update_attributes(params[:user])
      redirect_to @user
    else
      render :action => 'edit'
    end

  rescue ActiveRecord::RecordNotFound
    redirect_to users_url, notice: 'Invalid user'
  rescue
    redirect_to users_url, notice: 'Invalid parameter'
  end

  def edit
    @user = User.find(params[:id])
    @departments = Department.all
  rescue ActiveRecord::RecordNotFound
    redirect_to users_url, notice: 'Invalid user'
  end

  def deactivate
    @user = User.find(params[:id])
    if current_user == @user
      return redirect_to :back, :notice => 'Cannot disable yourself'
    end
    active_opening_count = Opening.published.owned_by(@user.id).count
    active_interview_count = @user.interviews.where(Interview.arel_table[:status].not_eq(Interview::STATUS_CLOSED)).count
    items = []
    items << "active openings" if active_opening_count > 0
    items << "active interviews" if active_interview_count > 0
    if items.first
      return redirect_to users_url, notice: "Cannot disable user assigned with #{items.join(' or ')}."
    end
    #It's ok to remove all 'potential interviewers' for this user
    @user.opening_participants.destroy_all
    toggle(params, false)
  #rescue
  #  redirect_to users_url, notice: 'Invalid user'
  end

  def reactivate
    @user = User.find(params[:id])
    toggle(params, true)
  rescue
    redirect_to users_url, notice: 'Invalid user'
  end

  private

  def toggle(params, active)
    @user = User.find(params[:id])
    option = {:deleted_at => (active ? nil : Time.current)}
    if @user.update_without_password(option) && @user.save
      redirect_to users_url
    else
      redirect_to users_url, :notice => "Operation Failed, error = #{@user.errors.inspect}"
    end
  end

  private


end
