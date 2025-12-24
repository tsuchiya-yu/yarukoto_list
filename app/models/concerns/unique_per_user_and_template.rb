module UniquePerUserAndTemplate
  extend ActiveSupport::Concern

  included do
    class_attribute :unique_per_user_and_template_message_key, default: nil
    validate :ensure_uniqueness_on_create, on: :create
  end

  private

  def ensure_uniqueness_on_create
    return if user_id.blank? || template_id.blank?

    if self.class.exists?(user_id: user_id, template_id: template_id)
      errors.add(:base, I18n.t(self.class.unique_per_user_and_template_message_key))
    end
  end
end
