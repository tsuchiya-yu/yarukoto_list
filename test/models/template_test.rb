require "test_helper"

class TemplateTest < ActiveSupport::TestCase
  setup do
    @template = templates(:moving)
  end

  test "フィクスチャのテンプレートは有効" do
    assert @template.valid?
  end

  test "タイトルは120文字以内" do
    @template.title = "a" * 121

    assert_not @template.valid?
  end

  test "author_notesは500文字以内" do
    @template.author_notes = "a" * 501

    assert_not @template.valid?
  end

  test "average_ratingは平均値を返す" do
    assert_in_delta 5.0, @template.average_rating, 0.001
  end
end
