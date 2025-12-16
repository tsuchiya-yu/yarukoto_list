class User < ApplicationRecord
  has_many :templates, dependent: :destroy
  has_many :template_reviews, dependent: :destroy
  has_many :template_ratings, dependent: :destroy
  has_many :user_lists, dependent: :destroy

  validates :name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, uniqueness: true, length: { maximum: 255 }
  validates :password_digest, presence: true
end
