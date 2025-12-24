class TemplateReview < ApplicationRecord
  belongs_to :template
  belongs_to :user

  validates :content,
            presence: { message: I18n.t("errors.messages.review_content_blank") },
            length: { maximum: 1000, message: I18n.t("errors.messages.review_content_too_long") }
  validates :user_id,
            uniqueness: {
              scope: :template_id,
              message: I18n.t("errors.messages.review_already_exists")
            }
end
