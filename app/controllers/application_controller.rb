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
    return if !request.get? || request.xhr? || [login_path, signup_path].include?(request.path)

    session[:return_to] = request.fullpath
  end

  def establish_session_for(user)
    pending_path = session[:return_to]
    reset_session
    session[:user_id] = user.id
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

  def user_list_show_props(user_list, errors: {})
    {
      user_list: UserListPresenter.new(user_list).detail,
      fixed_notice: fixed_notice_text,
      meta: meta_payload(
        "自分用リスト",
        "自分用に追加したリストの内容を確認できます。"
      ),
      errors: errors
    }
  end

  def public_template_show_props(template, errors: {})
    {
      template: TemplatePresenter.new(template, current_user).detail,
      fixed_notice: fixed_notice_text,
      review_notice: review_notice_text,
      meta: meta_payload(
        template.title,
        helpers.public_template_meta_description(template)
      ),
      errors: errors
    }
  end

  def fixed_notice_text
    <<~TEXT.strip
      ※本サービスで提供されるやることリストは、一般的な情報をもとにした参考例です。
      手続きの要否や内容は、契約内容・地域・個別状況によって異なる場合があります。
      必ず公式サイトや契約書などの一次情報もあわせてご確認ください。
    TEXT
  end

  def review_notice_text
    <<~TEXT.strip
      ※本サービスで提供されるやることリストは、一般的な情報や個人の体験をもとにした参考例です。
      手続きの要否や内容は、契約内容・地域・個別状況によって異なる場合があります。
    TEXT
  end

  def user_payload(user)
    {
      id: user.id,
      name: user.name
    }
  end
end
