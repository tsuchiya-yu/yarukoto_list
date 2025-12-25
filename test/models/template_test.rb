require "test_helper"

class TemplateTest < ActiveSupport::TestCase
  test "フィクスチャのテンプレは有効" do
    assert templates(:moving).valid?
  end

  test "タイトルは120文字以内" do
    template = templates(:moving)
    template.title = "a" * 121

    assert_not template.valid?
  end

  test "author_notesは500文字以内" do
    template = templates(:moving)
    template.author_notes = "a" * 501

    assert_not template.valid?
  end

  test "average_ratingは平均値を返す" do
    template = templates(:moving)

    assert_in_delta 5.0, template.average_rating, 0.001
  end
end
