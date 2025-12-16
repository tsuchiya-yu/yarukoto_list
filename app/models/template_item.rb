class TemplateItem < ApplicationRecord
  belongs_to :template
  has_many :user_list_items, dependent: :nullify

  validates :title, presence: true
  validates :position, numericality: { greater_than_or_equal_to: 0 }
end
