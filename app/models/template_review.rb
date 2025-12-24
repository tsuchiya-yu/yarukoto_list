class TemplateReview < ApplicationRecord
  belongs_to :template
  belongs_to :user

  validates :content,
            presence: { message: I18n.t("errors.messages.review_content_blank") },
            length: { maximum: 1000, message: I18n.t("errors.messages.review_content_too_long") }
  validate :ensure_uniqueness_on_create, on: :create

  private

  def ensure_uniqueness_on_create
    return if user_id.blank? || template_id.blank?

    if self.class.exists?(user_id: user_id, template_id: template_id)
      errors.add(:base, I18n.t("errors.messages.review_already_exists"))
    end
  end
end
