require "test_helper"

class UserListTest < ActiveSupport::TestCase
  test "フィクスチャの自分用リストは有効" do
    assert user_lists(:taro_moving_list).valid?
  end

  test "同じユーザーとテンプレートの組み合わせは重複できない" do
    user = users(:taro)
    template = templates(:moving)

    user_list = UserList.new(
      user: user,
      template: template,
      title: "重複のやること",
      description: "重複テスト",
      position: 0
    )

    assert_not user_list.valid?
    assert_includes user_list.errors[:template_id], "このリストはすでに自分用に追加済みです"
  end

  test "positionは0以上が必要" do
    user_list = user_lists(:taro_moving_list)
    user_list.position = -1

    assert_not user_list.valid?
  end
end
