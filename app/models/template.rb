class Template < ApplicationRecord
  belongs_to :user
  has_many :template_items, -> { order(:position) }, dependent: :destroy
  has_many :template_reviews, -> { order(created_at: :desc) }, dependent: :destroy
  has_many :template_ratings, dependent: :destroy
  has_many :user_lists, dependent: :destroy

  validates :title, presence: true, length: { maximum: 120 }
  validates :description, presence: true
  validates :author_notes, length: { maximum: 500 }, allow_blank: true

  scope :with_public_stats, lambda {
    joins(
      <<~SQL.squish
        LEFT JOIN (
          SELECT template_id, AVG(score) AS average_score, COUNT(*) AS ratings_count
          FROM template_ratings
          GROUP BY template_id
        ) rating_stats ON rating_stats.template_id = templates.id
        LEFT JOIN (
          SELECT template_id, COUNT(*) AS reviews_count
          FROM template_reviews
          GROUP BY template_id
        ) review_stats ON review_stats.template_id = templates.id
        LEFT JOIN (
          SELECT template_id, COUNT(*) AS copies_count
          FROM user_lists
          GROUP BY template_id
        ) copy_stats ON copy_stats.template_id = templates.id
      SQL
    ).select(
      <<~SQL.squish
        templates.*,
        COALESCE(rating_stats.average_score, 0) AS average_score,
        COALESCE(rating_stats.ratings_count, 0) AS ratings_count,
        COALESCE(review_stats.reviews_count, 0) AS reviews_count,
        COALESCE(copy_stats.copies_count, 0) AS copies_count
      SQL
    )
  }

  # NOTE: These scopes rely on aggregated columns loaded by `with_public_stats`.
  scope :order_by_popularity, lambda {
    order(Arel.sql("copies_count DESC"), Arel.sql("ratings_count DESC"), updated_at: :desc)
  }

  scope :order_by_rating, lambda {
    order(Arel.sql("average_score DESC"), Arel.sql("ratings_count DESC"), updated_at: :desc)
  }

  scope :order_by_newest, -> { order(created_at: :desc) }
  scope :find_for_public_show, lambda { |id|
    with_public_stats
      .includes(:user, :template_items, :template_ratings, template_reviews: :user)
      .find(id)
  }

  def average_rating
    template_ratings.average(:score)&.to_f || 0.0
  end

  def public_average_score
    self[:average_score].to_f
  end

  def public_ratings_count
    self[:ratings_count].to_i
  end

  def public_reviews_count
    self[:reviews_count].to_i
  end

  def public_copies_count
    self[:copies_count].to_i
  end
end
