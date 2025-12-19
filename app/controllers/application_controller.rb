class ApplicationController < ActionController::Base
  include InertiaRails::Controller

  before_action :require_login
  helper_method :current_user

  inertia_share flash: -> { { notice: flash[:notice], alert: flash[:alert] }.compact },
                auth: -> { { user: current_user && user_payload(current_user) } }

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id].present?
  end

  def require_login
    return if current_user

    store_location_for_login
    redirect_to login_path, alert: "ログインすると利用できます"
  end

  def store_location_for_login
    return unless request.get?
    return if request.xhr?
    return if [login_path, register_path].include?(request.path)

    session[:return_to] = request.fullpath
  end

  def establish_session_for(user)
    pending_path = session[:return_to]
    reset_session
    session[:user_id] = user.id
    @current_user = user
    pending_path.presence || root_path
  end

  def redirect_if_authenticated
    return unless current_user

    redirect_to root_path, notice: "すでにログイン済みです"
  end

  def meta_payload(title, description)
    {
      title: title,
      description: description,
      og_title: "#{title} | やることリスト",
      og_description: description,
      og_image: "/apple-touch-icon.png"
    }
  end

  def user_payload(user)
    {
      id: user.id,
      name: user.name,
      email: user.email
    }
  end
end
