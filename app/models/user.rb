class User < ApplicationRecord
  has_secure_password

  has_many :templates, dependent: :destroy
  has_many :template_reviews, dependent: :destroy
  has_many :template_ratings, dependent: :destroy
  has_many :user_lists, dependent: :destroy

  before_save :normalize_email

  validates :name, presence: true, length: { maximum: 50 }
  validates :email,
            presence: true,
            length: { maximum: 255 },
            format: { with: URI::MailTo::EMAIL_REGEXP },
            uniqueness: { case_sensitive: false }

  private

  def normalize_email
    email&.downcase!
  end
end
