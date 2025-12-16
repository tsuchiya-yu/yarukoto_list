class TemplateReview < ApplicationRecord
  belongs_to :template
  belongs_to :user

  validates :content, presence: true, length: { maximum: 1000 }
end
