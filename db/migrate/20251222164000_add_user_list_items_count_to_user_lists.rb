class AddUserListItemsCountToUserLists < ActiveRecord::Migration[7.1]
  def change
    add_column :user_lists, :user_list_items_count, :integer, null: false, default: 0

    reversible do |dir|
      dir.up do
        UserList.reset_column_information
        UserList.find_each do |list|
          UserList.reset_counters(list.id, :user_list_items)
        end
      end
    end
  end
end
