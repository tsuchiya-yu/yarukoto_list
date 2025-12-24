class TemplateRating < ApplicationRecord
  belongs_to :template
  belongs_to :user

  validates :score, inclusion: { in: 1..5, message: I18n.t("errors.messages.rating_score_invalid") }
  validate :ensure_uniqueness_on_create, on: :create

  private

  def ensure_uniqueness_on_create
    return if user_id.blank? || template_id.blank?

    if self.class.exists?(user_id: user_id, template_id: template_id)
      errors.add(:base, I18n.t("errors.messages.rating_already_exists"))
    end
  end
end
