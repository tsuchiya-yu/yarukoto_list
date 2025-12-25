require "test_helper"

class TemplateReviewTest < ActiveSupport::TestCase
  test "フィクスチャのレビューは有効" do
    assert template_reviews(:moving_review).valid?
  end

  test "内容は必須" do
    review = template_reviews(:moving_review)
    review.content = ""

    assert_not review.valid?
    assert review.errors[:content].any?
  end

  test "内容は1000文字以内" do
    review = template_reviews(:moving_review)
    review.content = "a" * 1001

    assert_not review.valid?
    assert review.errors[:content].any?
  end

  test "同じユーザーとテンプレートの組み合わせは重複できない" do
    review = TemplateReview.new(
      template: templates(:moving),
      user: users(:hanako),
      content: "重複テスト"
    )

    assert_not review.valid?
    assert_includes review.errors[:base], I18n.t("errors.messages.review_already_exists")
  end
end
