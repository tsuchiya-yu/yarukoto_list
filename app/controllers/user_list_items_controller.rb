class UserListItemsController < ApplicationController
  before_action :set_user_list
  before_action :set_user_list_item, only: %i[update destroy toggle]

  def create
    item =
      @user_list.user_list_items.new(
        user_list_item_params
      )

    UserListItem.transaction do
      @user_list.lock!
      item.position = @user_list.user_list_items.maximum(:position).to_i + 1
      item.save!
    end

    redirect_to user_list_path(@user_list), notice: "やることを追加しました"
  rescue ActiveRecord::RecordInvalid
    @user_list.user_list_items.reload
    render inertia: "UserLists/Show",
           props: user_list_show_props(@user_list, errors: formatted_errors(item)),
           status: :unprocessable_entity
  end

  def update
    @user_list_item.update!(update_params)
    redirect_to user_list_path(@user_list), notice: "やることを更新しました"
  rescue ActiveRecord::RecordInvalid
    render inertia: "UserLists/Show",
           props: user_list_show_props(@user_list, errors: formatted_errors(@user_list_item)),
           status: :unprocessable_entity
  end

  def toggle
    @user_list_item.update!(completed: !@user_list_item.completed)
    redirect_to user_list_path(@user_list), notice: "完了状態を更新しました"
  rescue ActiveRecord::RecordInvalid
    render inertia: "UserLists/Show",
           props: user_list_show_props(@user_list, errors: formatted_errors(@user_list_item)),
           status: :unprocessable_entity
  end

  def destroy
    UserListItem.transaction do
      @user_list.lock!
      @user_list_item.destroy!
      normalize_positions(@user_list)
    end

    redirect_to user_list_path(@user_list), notice: "やることを消しました"
  rescue ActiveRecord::RecordNotDestroyed, ActiveRecord::RecordInvalid
    @user_list.user_list_items.reload
    render inertia: "UserLists/Show",
           props: user_list_show_props(@user_list, errors: { base: "やることを消せませんでした" }),
           status: :unprocessable_entity
  end

  def reorder
    raw_item_ids = params[:item_ids]
    normalized_ids =
      if raw_item_ids.is_a?(String)
        raw_item_ids.split(",")
      else
        Array(raw_item_ids)
      end

    item_ids =
      normalized_ids.filter_map do |id|
        id.is_a?(Integer) ? id : Integer(id, 10)
      rescue ArgumentError, TypeError
        nil
      end

    UserListItem.transaction do
      @user_list.lock!
      all_ids = @user_list.user_list_items.order(:position, :id).pluck(:id)
      if item_ids.blank? || item_ids.uniq.size != item_ids.size || item_ids.sort != all_ids.sort
        @user_list.user_list_items.reload
        return render inertia: "UserLists/Show",
                      props: user_list_show_props(
                        @user_list,
                        errors: { base: "リストが更新されたため、並び替えできませんでした。ページを再読み込みしてください。" }
                      ),
                      status: :unprocessable_entity
      end
      ordered_ids = item_ids

      update_positions_in_order(@user_list, ordered_ids)
    end

    redirect_to user_list_path(@user_list), notice: "並び順を保存しました"
  end

  private

  def set_user_list
    @user_list = current_user.user_lists.includes(:user_list_items).find(params[:user_list_id])
  end

  def set_user_list_item
    @user_list_item = @user_list.user_list_items.find(params[:id])
  end

  def user_list_item_params
    params.require(:user_list_item).permit(:title, :description)
  end

  def update_params
    params.require(:user_list_item).permit(:completed)
  end

  def formatted_errors(record)
    record.errors.messages.transform_values(&:first)
  end

  def normalize_positions(user_list)
    ordered_ids = user_list.user_list_items.order(:position, :id).pluck(:id)
    update_positions_in_order(user_list, ordered_ids)
  end

  def update_positions_in_order(user_list, ordered_ids)
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
