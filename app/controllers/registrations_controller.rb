class RegistrationsController < ApplicationController
  skip_before_action :require_login, only: %i[new create]
  before_action :redirect_if_authenticated, only: %i[new create]

  def new
    render inertia: "Auth/Register", props: register_props
  end

  def create
    user = User.new(registration_params)
    if user.save
      redirect_to establish_session_for(user), notice: "アカウントを作成しました"
    else
      render inertia: "Auth/Register",
             props: register_props(form: registration_params, errors: formatted_errors(user)),
             status: :unprocessable_entity
    end
  end

  private

  def registration_params
    params.permit(:name, :email, :password, :password_confirmation)
  end

  def register_props(form: {}, errors: {})
    description =
      "メールアドレスとパスワードを設定して、やることリストを自分用に管理できるようにします。登録後はログイン済みの状態でヘッダーに表示されます。"
    {
      meta: meta_payload("はじめて使う", description),
      form: {
        name: form[:name].to_s,
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

  def formatted_errors(record)
    record.errors.to_hash(true).transform_values { |messages| Array(messages).first }
  end

  def redirect_if_authenticated
    return unless current_user

    redirect_to root_path, notice: "すでにログイン済みです"
  end
end
