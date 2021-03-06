class UserController < ApplicationController
  before_filter :require_admin

  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:userid])

    # TODO: Display jobs created by users
    @user_jobs = @user.jobs
  end

  def new
    @user ||= User.new
  end

  def create
    # TODO: verify password's match

    u = User.new(user_params)
    u.api_token = gen_api_token
    u.api_token_changed = DateTime.now
    u.save

    if u.persisted?
      flash[:notice] = "Account #{u.email} created successfully"
      redirect_to users_path
    else
      flash[:alert] = u.errors.full_messages.join("\n")
      # TODO: change this to use creation path
      redirect_to root_path
    end
  end

  def edit
    @user = User.find(params[:userid])
  end

  def update
    @user = User.find(params[:userid])
    @user.update_attributes(user_params)

    if @user.save!
      flash[:notice] = "Account #{@user.email} updated successfully"
      redirect_to users_path
    else
      flash[:alert] = @user.errors.full_messages.join("\n")
      redirect_to user_path(@user)
    end
  end

  def destroy
    @user = User.find(params[:userid])

    @user.destroy

    if @user.destroyed?
      flash[:notice] = "Account #{@user.email} deleted successfully"
      redirect_to users_path
    else
      flash[:alert] = @user.errors.full_messages.join("\n")
      redirect_to user_path(@user)
    end
  end

  private
  def user_params
    params.require(:user).permit(:email, :password, :admin)
  end

  def gen_api_token
    SecureRandom.base64(64)
  end
end
