class SessionsController < ApplicationController
  skip_before_action :require_login, only: %i[new create]
  before_action :redirect_if_authenticated, only: %i[new create]

  def new
    render inertia: "Auth/Login", props: login_props
  end

  def create
    user = User.find_by("LOWER(email) = ?", session_params[:email].to_s.downcase)
    if user&.authenticate(session_params[:password])
      redirect_to establish_session_for(user), notice: "ログインしました"
    else
      render inertia: "Auth/Login",
             props:
               login_props(
                 form: { email: session_params[:email] },
                 errors: { email: "メールアドレスまたはパスワードが正しくありません" }
               ),
             status: :unprocessable_entity
    end
  end

  def destroy
    reset_session
    redirect_to root_path, notice: "ログアウトしました"
  end

  private

  def session_params
    params.permit(:email, :password)
  end

  def login_props(form: {}, errors: {})
    description =
      "やることリストにログインして、自分用にコピーする準備を進めましょう。ログイン後はヘッダーからいつでもログアウトできます。"
    {
      meta: meta_payload("ログインする", description),
      form: {
        email: form[:email].to_s
      },
      errors: errors
    }
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

  def redirect_if_authenticated
    return unless current_user

    redirect_to root_path, notice: "すでにログイン済みです"
  end
end
