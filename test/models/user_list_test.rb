require "test_helper"

class UserListTest < ActiveSupport::TestCase
  setup do
    @user_list = user_lists(:taro_moving_list)
  end

  test "フィクスチャの自分用リストは有効" do
    assert @user_list.valid?
  end

  test "同じユーザーとテンプレートの組み合わせは重複できない" do
    duplicate_list = @user_list.dup

    assert_not duplicate_list.valid?
    assert_includes duplicate_list.errors[:template_id], I18n.t("errors.messages.user_list_already_added")
  end

  test "positionは0以上が必要" do
    @user_list.position = -1

    assert_not @user_list.valid?
  end
end
