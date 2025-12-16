class Template < ApplicationRecord
  belongs_to :user
  has_many :template_items, -> { order(:position) }, dependent: :destroy
  has_many :template_reviews, dependent: :destroy
  has_many :template_ratings, dependent: :destroy
  has_many :user_lists, dependent: :destroy

  validates :title, presence: true, length: { maximum: 120 }
  validates :description, presence: true
  validates :author_notes, length: { maximum: 500 }, allow_blank: true

  def average_rating
    template_ratings.average(:score)&.to_f
  end
end
