require "test_helper"

class TemplateRatingTest < ActiveSupport::TestCase
  setup do
    @rating = template_ratings(:moving_rating)
  end

  test "フィクスチャの評価は有効" do
    assert @rating.valid?
  end

  test "評価は1から5の範囲外で無効" do
    [0, 6].each do |invalid_score|
      @rating.score = invalid_score

      assert_not @rating.valid?, "score: #{invalid_score} should be invalid"
      assert_includes @rating.errors[:score], I18n.t("errors.messages.rating_score_invalid")
    end
  end

  test "同じユーザーとテンプレートの組み合わせは重複できない" do
    duplicate_rating = @rating.dup

    assert_not duplicate_rating.valid?
    assert_includes duplicate_rating.errors[:base], I18n.t("errors.messages.rating_already_exists")
  end
end
