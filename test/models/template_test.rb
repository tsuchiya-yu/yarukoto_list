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

  test "average_ratingは評価がない場合に0.0を返す" do
    template_without_ratings = templates(:packing)

    assert_equal 0.0, template_without_ratings.average_rating
  end
end
