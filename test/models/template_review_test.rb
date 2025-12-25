require "test_helper"

class TemplateReviewTest < ActiveSupport::TestCase
  setup do
    @review = template_reviews(:moving_review)
  end

  test "フィクスチャのレビューは有効" do
    assert @review.valid?
  end

  test "内容は必須" do
    @review.content = ""

    assert_not @review.valid?
    assert_includes @review.errors[:content], I18n.t("errors.messages.review_content_blank")
  end

  test "内容は1000文字以内" do
    @review.content = "a" * 1001

    assert_not @review.valid?
    assert_includes @review.errors[:content], I18n.t("errors.messages.review_content_too_long")
  end

  test "同じユーザーとテンプレートの組み合わせは重複できない" do
    duplicate_review = @review.dup

    assert_not duplicate_review.valid?
    assert_includes duplicate_review.errors[:base], I18n.t("errors.messages.review_already_exists")
  end
end
