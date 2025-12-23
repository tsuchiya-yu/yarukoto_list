class UserListItemsController < ApplicationController
  before_action :set_user_list
  before_action :set_user_list_item, only: %i[update destroy]

  def create
    item =
      @user_list.user_list_items.new(
        user_list_item_params
      )

    UserListItem.transaction do
      @user_list.lock!
      item.position = (@user_list.user_list_items.maximum(:position) || -1) + 1
      item.save!
    end

    redirect_to user_list_path(@user_list), notice: "やることを追加しました"
  rescue ActiveRecord::RecordInvalid
    render inertia: "UserLists/Show",
           props: user_list_show_props(@user_list, errors: formatted_errors(item)),
           status: :unprocessable_entity
  end

  def update
    if @user_list_item.update(update_params)
      redirect_to user_list_path(@user_list)
    else
      render inertia: "UserLists/Show",
             props: user_list_show_props(@user_list, errors: formatted_errors(@user_list_item)),
             status: :unprocessable_entity
    end
  end

  def destroy
    if @user_list_item.destroy
      redirect_to user_list_path(@user_list), notice: "やることを消しました"
    else
      redirect_to user_list_path(@user_list), alert: "やることを消せませんでした"
    end
  end

  def reorder
    item_ids =
      Array(params[:item_ids])
      .filter_map { |id| Integer(id, 10) rescue nil }
      .uniq
    items = @user_list.user_list_items.where(id: item_ids)
    if item_ids.blank? || items.size != item_ids.size
      return redirect_to user_list_path(@user_list), alert: "並び替えに失敗しました"
    end

    now = Time.current
    case_sql = item_ids.each_with_index.map { |id, index| "WHEN #{id} THEN #{index}" }.join(" ")

    items.update_all(["position = CASE id #{case_sql} END, updated_at = ?", now])

    redirect_to user_list_path(@user_list)
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
end
