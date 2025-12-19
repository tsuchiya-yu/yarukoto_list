class SessionsController < ApplicationController
  skip_before_action :require_login, only: %i[new create]
  before_action :redirect_if_authenticated, only: %i[new create]

  def new
    render inertia: "Auth/Login", props: login_props
  end

  def create
    permitted = session_params
    email = permitted[:email]&.downcase
    user = User.find_by(email: email) if email
    if user&.authenticate(permitted[:password])
      redirect_to establish_session_for(user), notice: "ログインしました"
    else
      render inertia: "Auth/Login",
             props:
               login_props(
                 form: { email: permitted[:email] },
                 errors: { base: "メールアドレスまたはパスワードが正しくありません" }
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
    params.require(:session).permit(:email, :password)
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

end
