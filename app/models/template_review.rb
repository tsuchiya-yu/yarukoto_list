class TemplateReview < ApplicationRecord
  belongs_to :template
  belongs_to :user

  include UniquePerUserAndTemplate

  self.unique_per_user_and_template_message_key = "errors.messages.review_already_exists"

  validates :content,
            presence: { message: I18n.t("errors.messages.review_content_blank") },
            length: { maximum: 1000, message: I18n.t("errors.messages.review_content_too_long") }
end
