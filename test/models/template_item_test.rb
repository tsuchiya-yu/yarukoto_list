require "test_helper"

class TemplateItemTest < ActiveSupport::TestCase
  test "フィクスチャのテンプレ項目は有効" do
    assert template_items(:moving_step1).valid?
  end

  test "タイトルは必須" do
    item = template_items(:moving_step1)
    item.title = ""

    assert_not item.valid?
  end

  test "positionは0以上が必要" do
    item = template_items(:moving_step1)
    item.position = -1

    assert_not item.valid?
  end
end
