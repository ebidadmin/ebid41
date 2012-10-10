class SessionsController < Devise::SessionsController
  skip_before_filter :authenticate_user!, unless: :devise_controller?

  def new
  end
end
