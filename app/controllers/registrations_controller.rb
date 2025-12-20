class RegistrationsController < ApplicationController
  skip_before_action :require_login, only: %i[new create]
  before_action :redirect_if_authenticated, only: %i[new create]

  def new
    render inertia: "Auth/Register", props: register_props
  end

  def create
    permitted = registration_params
    user = User.new(permitted)
    if user.save
      redirect_to establish_session_for(user), notice: "アカウントを作成しました"
    else
      render inertia: "Auth/Register",
             props: register_props(form: permitted.slice(:name, :email), errors: formatted_errors(user)),
             status: :unprocessable_entity
    end
  end

  private

  def registration_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def register_props(form: {}, errors: {})
    description =
      "メールアドレスとパスワードを設定して、やることリストを自分用に管理できるようにします。アカウント作成後はログイン済みの状態でヘッダーに表示されます。"
    {
      meta: meta_payload("はじめて使う", description),
      form: {
        name: form[:name].to_s,
        email: form[:email].to_s
      },
      errors: errors
    }
  end

  def formatted_errors(record)
    record.errors.to_hash(true).transform_values { |messages| messages.first.to_s }
  end

end
