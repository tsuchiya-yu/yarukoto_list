class TemplateRating < ApplicationRecord
  belongs_to :template
  belongs_to :user

  validates :score, inclusion: { in: 1..5 }
  validates :user_id, uniqueness: { scope: :template_id }
end
