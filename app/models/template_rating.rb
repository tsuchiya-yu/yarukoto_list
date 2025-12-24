class TemplateRating < ApplicationRecord
  belongs_to :template
  belongs_to :user

  validates :score, inclusion: { in: 1..5, message: "★評価は1〜5で選んでください。" }
  validates :user_id,
            uniqueness: {
              scope: :template_id,
              message: "このリストへの★評価はすでに投稿済みです。内容を編集してください。"
            }
end
