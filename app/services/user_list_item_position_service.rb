class UserListItemPositionService
  def self.normalize_positions(user_list)
    ordered_ids = user_list.user_list_items.order(:position, :id).pluck(:id)
    update_positions_in_order(user_list, ordered_ids)
  end

  def self.update_positions_in_order(user_list, ordered_ids)
    return if ordered_ids.empty?

    now = Time.current
    case_sql =
      ordered_ids
      .each_with_index
      .map { |id, index| "WHEN #{id} THEN #{index + 1}" }
      .join(" ")
    user_list.user_list_items.update_all(
      ["position = CASE id #{case_sql} END, updated_at = ?", now]
    )
  end
end
