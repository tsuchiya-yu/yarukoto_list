class UserListItemsController < ApplicationController
  before_action :set_user_list
  before_action :set_user_list_item, only: %i[update destroy]

  def create
    item =
      @user_list.user_list_items.new(
        user_list_item_params.merge(position: next_position_for(@user_list))
      )

    if item.save
      redirect_to user_list_path(@user_list), notice: "やることを追加しました"
    else
      render inertia: "UserLists/Show",
             props: show_props(@user_list, errors: formatted_errors(item)),
             status: :unprocessable_entity
    end
  end

  def update
    if @user_list_item.update(update_params)
      redirect_to user_list_path(@user_list)
    else
      render inertia: "UserLists/Show",
             props: show_props(@user_list, errors: formatted_errors(@user_list_item)),
             status: :unprocessable_entity
    end
  end

  def destroy
    @user_list_item.destroy!
    redirect_to user_list_path(@user_list), notice: "やることを消しました"
  end

  def reorder
    item_ids = Array(params[:item_ids]).map(&:to_i).uniq
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

  def next_position_for(user_list)
    user_list.user_list_items.lock.order(position: :desc).limit(1).pick(:position).to_i + 1
  end

  def show_props(user_list, errors: {})
    {
      user_list: UserListPresenter.new(user_list).detail,
      fixed_notice: fixed_notice_text,
      meta: meta_payload(
        "自分用リスト",
        "自分用に追加したリストの内容を確認できます。"
      ),
      form_errors: errors
    }
  end

  def formatted_errors(record)
    record.errors.messages.transform_values(&:first)
  end
end
