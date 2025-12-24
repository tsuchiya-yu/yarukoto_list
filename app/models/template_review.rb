class TemplateReview < ApplicationRecord
  belongs_to :template
  belongs_to :user

  validates :content,
            presence: { message: "レビューを入力してください。" },
            length: { maximum: 1000, message: "レビューは1000文字以内で入力してください。" }
  validates :user_id,
            uniqueness: {
              scope: :template_id,
              message: I18n.t("errors.messages.review_already_exists")
            }
end
