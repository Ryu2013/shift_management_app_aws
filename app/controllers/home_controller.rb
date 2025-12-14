class HomeController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :office_authenticate
  skip_before_action :user_authenticate

  def index
  end
end
