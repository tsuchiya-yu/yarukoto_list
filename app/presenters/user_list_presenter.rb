class UserListPresenter
  def initialize(user_list)
    @user_list = user_list
  end

  def summary
    {
      id: @user_list.id,
      title: @user_list.title,
      created_at: @user_list.created_at.iso8601,
      items_count: @user_list.user_list_items_count
    }
  end

  def detail
    # N+1回避のため、呼び出し元で user_list_items を includes しておく
    {
      id: @user_list.id,
      title: @user_list.title,
      description: @user_list.description,
      created_at: @user_list.created_at.iso8601,
      items_count: @user_list.user_list_items_count,
      items: @user_list.user_list_items.map do |item|
        {
          id: item.id,
          title: item.title,
          description: item.description,
          completed: item.completed,
          position: item.position
        }
      end
    }
  end
end
