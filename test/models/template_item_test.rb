require "test_helper"

class TemplateItemTest < ActiveSupport::TestCase
  setup do
    @item = template_items(:moving_step1)
  end

  test "フィクスチャのテンプレート項目は有効" do
    assert @item.valid?
  end

  test "タイトルは必須" do
    @item.title = ""

    assert_not @item.valid?
    assert_not_empty @item.errors[:title]
  end

  test "positionは0以上が必要" do
    @item.position = -1

    assert_not @item.valid?
    assert_not_empty @item.errors[:position]
  end
end
