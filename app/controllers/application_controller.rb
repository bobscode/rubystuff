class ApplicationController < ActionController::Base
  before_filter :select_region

  helper_method :logged_in?

  def require_user
    puts "redirecting to #{login_url(:region => @region)}"
    unless(logged_in?)
      redirect_to login_url(:region => @region)
      flash[:error] = "You must be logged in to use this feature."
    end
    @user = env["warden"].user(:participant)
  end

  protect_from_forgery

  private

  def select_region
    @region = params[:region]
  end

  def logged_in?
    env["warden"].user(:participant) && @region == env["warden"].user(:participant).region
  end
end
