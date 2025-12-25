require "test_helper"

class TemplateRatingTest < ActiveSupport::TestCase
  setup do
    @rating = template_ratings(:moving_rating)
  end

  test "フィクスチャの評価は有効" do
    assert @rating.valid?
  end

  test "評価は1から5の範囲" do
    @rating.score = 0

    assert_not @rating.valid?
    assert_includes @rating.errors[:score], I18n.t("errors.messages.rating_score_invalid")
  end

  test "同じユーザーとテンプレートの組み合わせは重複できない" do
    duplicate_rating = @rating.dup

    assert_not duplicate_rating.valid?
    assert_includes duplicate_rating.errors[:base], I18n.t("errors.messages.rating_already_exists")
  end
end
