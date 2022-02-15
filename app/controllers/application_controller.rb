class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  def authenticate_user!
    if session[:auth].present?
      # aa
    else
      redirect_to "/login"
    end
  end
end
