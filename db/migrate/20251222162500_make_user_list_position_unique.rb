class MakeUserListPositionUnique < ActiveRecord::Migration[7.1]
  def change
    if index_exists?(:user_lists, %i[user_id position], name: "index_user_lists_on_user_id_and_position")
      remove_index :user_lists, name: "index_user_lists_on_user_id_and_position"
    end

    add_index :user_lists, %i[user_id position], unique: true, name: "index_user_lists_on_user_id_and_position"
  end
end
