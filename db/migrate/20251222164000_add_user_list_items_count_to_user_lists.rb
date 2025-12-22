class AddUserListItemsCountToUserLists < ActiveRecord::Migration[7.1]
  def change
    add_column :user_lists, :user_list_items_count, :integer, null: false, default: 0

    reversible do |dir|
      dir.up do
        UserList.reset_column_information
        execute <<~SQL.squish
          UPDATE user_lists
          SET user_list_items_count = (
            SELECT COUNT(1)
            FROM user_list_items
            WHERE user_list_items.user_list_id = user_lists.id
          )
        SQL
      end
    end
  end
end
