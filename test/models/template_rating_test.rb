require "test_helper"

class TemplateRatingTest < ActiveSupport::TestCase
  test "フィクスチャの評価は有効" do
    assert template_ratings(:moving_rating).valid?
  end

  test "評価は1から5の範囲" do
    rating = template_ratings(:moving_rating)
    rating.score = 0

    assert_not rating.valid?
    assert_includes rating.errors[:score], I18n.t("errors.messages.rating_score_invalid")
  end

  test "同じユーザーとテンプレートの組み合わせは重複できない" do
    rating = TemplateRating.new(
      template: templates(:moving),
      user: users(:hanako),
      score: 4
    )

    assert_not rating.valid?
    assert_includes rating.errors[:base], I18n.t("errors.messages.rating_already_exists")
  end
end
