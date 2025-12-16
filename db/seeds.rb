# frozen_string_literal: true

require "securerandom"

ActiveRecord::Base.transaction do
  official_user = User.find_or_create_by!(email: "official@yarukoto.list") do |user|
    user.name = "運営チーム"
    user.password_digest = SecureRandom.hex(16)
  end

  template = Template.find_or_initialize_by(title: "はじめての引越し公式リスト")
  template.assign_attributes(
    user: official_user,
    description: "初めての引越しでも迷わず進められるよう、申し込みから引越し当日までの流れを整理したリストです。",
    author_notes: "ライフラインの解約・開栓手続きは地域で異なるため、最終的には公式サイトもご確認ください。"
  )
  template.save!

  template_items = [
    {
      title: "引越し日と予算を決める",
      description: "退去日と新居の入居可能日を合わせて、ざっくりしたスケジュールを固めます。"
    },
    {
      title: "引越し業者を比較・予約",
      description: "相見積もりを取り、希望日が空いている業者を確保します。"
    },
    {
      title: "役所・ライフラインの解約手続き",
      description: "電気・ガス・水道・インターネットの停止日を連絡します。"
    },
    {
      title: "新居側のライフライン契約",
      description: "電気・ガス・水道・ネット回線の開栓日を調整しておきます。"
    },
    {
      title: "荷造りと不要品整理",
      description: "段ボールや資材を揃えて、使わない部屋から順番に箱詰めします。"
    },
    {
      title: "引越し前日の最終確認",
      description: "貴重品・当日使う荷物を1つにまとめ、冷蔵庫の電源を切ります。"
    },
    {
      title: "転入届などの各種手続き",
      description: "住民票の移動や免許証の住所変更などを新居で済ませます。"
    }
  ]

  template.template_items.destroy_all
  template_items.each_with_index do |item, index|
    template.template_items.create!(item.merge(position: index))
  end

  reviewer_profiles = [
    {
      email: "reviewer01@example.com",
      name: "引越しベテラン",
      review: "順番通りに進めたら抜け漏れなく完了できました。",
      score: 5
    },
    {
      email: "reviewer02@example.com",
      name: "家族で引越し",
      review: "ライフラインの手続きがまとまっていて助かりました。",
      score: 4
    }
  ]

  reviewer_profiles.each do |profile|
    reviewer = User.find_or_create_by!(email: profile[:email]) do |user|
      user.name = profile[:name]
      user.password_digest = SecureRandom.hex(16)
    end

    TemplateReview.find_or_initialize_by(template:, user: reviewer).tap do |review|
      review.content = profile[:review]
      review.save!
    end

    TemplateRating.find_or_initialize_by(template:, user: reviewer).tap do |rating|
      rating.score = profile[:score]
      rating.save!
    end
  end

  demo_user = User.find_or_create_by!(email: "demo@yarukoto.list") do |user|
    user.name = "デモユーザー"
    user.password_digest = SecureRandom.hex(16)
  end

  user_list = UserList.find_or_initialize_by(user: demo_user, template: template)
  user_list.title = "#{template.title}（サンプル）"
  user_list.description = "公式リストを自分用にコピーした例です。"
  user_list.position = 0
  user_list.save!

  user_list.user_list_items.destroy_all
  template.template_items.order(:position).each do |item|
    user_list.user_list_items.create!(
      title: item.title,
      description: item.description,
      position: item.position,
      completed: item.position.zero?
    )
  end
end
