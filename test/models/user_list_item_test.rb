require "test_helper"

class UserListItemTest < ActiveSupport::TestCase
  test "フィクスチャのやることは有効" do
    assert user_list_items(:taro_moving_item).valid?
  end

  test "やることのタイトルは必須" do
    item = user_list_items(:taro_moving_item)
    item.title = ""

    assert_not item.valid?
    assert_includes item.errors[:title], "やることを入力してください"
  end

  test "positionは0以上が必要" do
    item = user_list_items(:taro_moving_item)
    item.position = -1

    assert_not item.valid?
  end

  test "template_itemがなくても作成できる" do
    item = UserListItem.new(
      user_list: user_lists(:taro_moving_list),
      template_item: nil,
      title: "新しいやること",
      description: "説明",
      position: 0
    )

    assert item.valid?
  end
end
