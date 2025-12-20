class AddUniqueIndexToUserLists < ActiveRecord::Migration[7.1]
  def change
    add_index :user_lists, %i[user_id template_id], unique: true
  end
end
