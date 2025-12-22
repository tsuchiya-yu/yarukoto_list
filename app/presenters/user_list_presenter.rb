class UserListPresenter
  def initialize(user_list)
    @user_list = user_list
  end

  def summary
    {
      id: @user_list.id,
      title: @user_list.title,
      created_at: @user_list.created_at.iso8601,
      items_count: @user_list.items_count.to_i
    }
  end

  def detail
    {
      id: @user_list.id,
      title: @user_list.title,
      description: @user_list.description,
      created_at: @user_list.created_at.iso8601,
      items: @user_list.user_list_items.map do |item|
        {
          id: item.id,
          title: item.title,
          description: item.description
        }
      end
    }
  end
end
