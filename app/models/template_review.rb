class TemplateReview < ApplicationRecord
  belongs_to :template
  belongs_to :user

  validates :content, presence: true, length: { maximum: 1000 }
  validates :user_id, uniqueness: { scope: :template_id }
end
