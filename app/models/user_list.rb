class UserList < ApplicationRecord
  belongs_to :user
  belongs_to :template
  has_many :user_list_items, -> { order(:position) }, dependent: :destroy

  validates :title, presence: true
  validates :position, numericality: { greater_than_or_equal_to: 0 }
  validates :template_id,
            uniqueness: { scope: :user_id, message: I18n.t("errors.messages.user_list_already_added") }
end
