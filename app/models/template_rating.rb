class TemplateRating < ApplicationRecord
  belongs_to :template
  belongs_to :user

  validates :score, inclusion: { in: 1..5, message: I18n.t("errors.messages.rating_score_invalid") }
  validates :user_id,
            uniqueness: {
              scope: :template_id,
              message: I18n.t("errors.messages.rating_already_exists")
            }
end
