class TemplateRating < ApplicationRecord
  belongs_to :template
  belongs_to :user

  include UniquePerUserAndTemplate

  self.unique_per_user_and_template_message_key = "errors.messages.rating_already_exists"

  validates :score, inclusion: { in: 1..5, message: I18n.t("errors.messages.rating_score_invalid") }
end
