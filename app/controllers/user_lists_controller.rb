class UserListsController < ApplicationController
  def index
    user_lists =
      current_user
      .user_lists
      .left_joins(:user_list_items)
      .select("user_lists.*, COUNT(user_list_items.id) AS items_count")
      .group("user_lists.id")
      .order(created_at: :desc)

    render inertia: "UserLists/Index", props: {
      user_lists: user_lists.map { |list| UserListPresenter.new(list).summary },
      fixed_notice: fixed_notice_text,
      meta: meta_payload(
        "自分用リスト",
        "自分用に追加したリストを一覧で確認できます。"
      )
    }
  end

  def show
    user_list = current_user.user_lists.includes(:user_list_items).find(params[:id])

    render inertia: "UserLists/Show", props: {
      user_list: UserListPresenter.new(user_list).detail,
      fixed_notice: fixed_notice_text,
      meta: meta_payload(
        "自分用リスト",
        "自分用に追加したリストの内容を確認できます。"
      )
    }
  end

  def create
    UserList.transaction do
      template = Template.includes(:template_items).lock.find(params[:template_id])
      current_user.with_lock do
        if current_user.user_lists.exists?(template: template)
          return redirect_to user_lists_path, notice: "このリストはすでに自分用に追加済みです"
        end

        copy_template_for(template)
      end
    end

    redirect_to user_lists_path, notice: "自分用リストを作成しました"
  rescue ActiveRecord::RecordInvalid
    redirect_to user_lists_path, alert: "自分用へのコピーに失敗しました"
  rescue ActiveRecord::RecordNotUnique
    redirect_to user_lists_path, notice: "このリストはすでに自分用に追加済みです"
  rescue ActiveRecord::RecordNotFound
    redirect_to public_templates_path, alert: "指定したやることリストが見つかりませんでした"
  end

  private

  def copy_template_for(template)
    user_list =
      current_user.user_lists.create!(
        template: template,
        title: template.title,
        description: template.description,
        position: next_position
      )

    timestamp = Time.current
    items_attributes =
      template.template_items.map do |item|
        {
          user_list_id: user_list.id,
          template_item_id: item.id,
          title: item.title,
          description: item.description,
          position: item.position,
          completed: false,
          created_at: timestamp,
          updated_at: timestamp
        }
      end
    UserListItem.insert_all!(items_attributes) if items_attributes.any?

    user_list
  end

  def next_position
    current_user.user_lists.order(position: :desc).limit(1).pick(:position).to_i + 1
  end
end
