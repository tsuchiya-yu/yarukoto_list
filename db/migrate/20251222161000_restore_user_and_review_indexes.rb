class RestoreUserAndReviewIndexes < ActiveRecord::Migration[7.1]
  def change
    if index_exists?(:users, :email, name: "index_users_on_email")
      remove_index :users, name: "index_users_on_email"
    end

    unless index_exists?(:users, "LOWER(email)", name: "index_users_on_lower_email")
      add_index :users, "LOWER(email)", unique: true, name: "index_users_on_lower_email"
    end

    unless index_exists?(:template_reviews, %i[template_id user_id], unique: true)
      add_index :template_reviews, %i[template_id user_id], unique: true,
                                                               name: "index_template_reviews_on_template_id_and_user_id"
    end
  end
end
