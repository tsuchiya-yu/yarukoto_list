require "test_helper"

class UserListItemTest < ActiveSupport::TestCase
  setup do
    @item = user_list_items(:taro_moving_item)
  end

  test "フィクスチャのやることは有効" do
    assert @item.valid?
  end

  test "やることのタイトルは必須" do
    @item.title = ""

    assert_not @item.valid?
    assert_includes @item.errors[:title], I18n.t("errors.messages.user_list_item_title_blank")
  end

  test "positionは0以上が必要" do
    @item.position = -1

    assert_not @item.valid?
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
