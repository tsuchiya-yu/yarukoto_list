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
  end

  test "positionは0以上が必要" do
    @item.position = -1

    assert_not @item.valid?
  end
end
