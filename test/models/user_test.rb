require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "有効なユーザーは保存できる" do
    user = User.new(
      name: "山田太郎",
      email: "taro@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    assert user.valid?
  end

  test "メールアドレスは小文字に正規化される" do
    user = User.create!(
      name: "山田太郎",
      email: "TARO@EXAMPLE.COM",
      password: "password123",
      password_confirmation: "password123"
    )

    assert_equal "taro@example.com", user.reload.email
  end
end
