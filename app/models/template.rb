class Template < ApplicationRecord
  belongs_to :user
  has_many :template_items, -> { order(:position) }, dependent: :destroy
  has_many :template_reviews, dependent: :destroy
  has_many :template_ratings, dependent: :destroy
  has_many :user_lists, dependent: :destroy

  validates :title, presence: true, length: { maximum: 120 }
  validates :description, presence: true
  validates :author_notes, length: { maximum: 500 }, allow_blank: true

  scope :with_public_stats, lambda {
    select(
      <<~SQL.squish
        templates.*,
        (
          SELECT COALESCE(AVG(template_ratings.score), 0)
          FROM template_ratings
          WHERE template_ratings.template_id = templates.id
        ) AS average_score,
        (
          SELECT COUNT(*)
          FROM template_ratings
          WHERE template_ratings.template_id = templates.id
        ) AS ratings_count,
        (
          SELECT COUNT(*)
          FROM template_reviews
          WHERE template_reviews.template_id = templates.id
        ) AS reviews_count,
        (
          SELECT COUNT(*)
          FROM user_lists
          WHERE user_lists.template_id = templates.id
        ) AS copies_count
      SQL
    )
  }

  def average_rating
    template_ratings.average(:score)&.to_f || 0.0
  end

  def public_average_score
    (self[:average_score] || average_rating).to_f
  end

  def public_ratings_count
    (self[:ratings_count] || template_ratings.size).to_i
  end

  def public_reviews_count
    (self[:reviews_count] || template_reviews.size).to_i
  end

  def public_copies_count
    (self[:copies_count] || user_lists.size).to_i
  end
end
