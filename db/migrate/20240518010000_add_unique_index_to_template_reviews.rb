class AddUniqueIndexToTemplateReviews < ActiveRecord::Migration[7.1]
  def change
    add_index :template_reviews, %i[template_id user_id], unique: true
  end
end
