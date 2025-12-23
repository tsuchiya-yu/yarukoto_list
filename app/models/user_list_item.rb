class UserListItem < ApplicationRecord
  belongs_to :user_list, counter_cache: true
  belongs_to :template_item, optional: true

  validates :title, presence: true
  validates :position, numericality: { greater_than_or_equal_to: 0 }
end
