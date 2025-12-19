class UserListsController < ApplicationController
  def create
    template = Template.includes(:template_items).find(params[:template_id])
    existing_list = current_user.user_lists.find_by(template: template)

    return redirect_to public_template_path(template), notice: "このリストはすでに自分用に追加済みです" if existing_list

    copy_template_for(template)
    redirect_to public_template_path(template), notice: "自分用リストを作成しました"
  rescue ActiveRecord::RecordInvalid
    redirect_to public_template_path(template), alert: "自分用へのコピーに失敗しました"
  rescue ActiveRecord::RecordNotFound
    redirect_to public_templates_path, alert: "指定したやることリストが見つかりませんでした"
  end

  private

  def copy_template_for(template)
    UserList.transaction do
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
  end

  def next_position
    current_user.user_lists.lock.maximum(:position).to_i + 1
  end
end
