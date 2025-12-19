module Public
  class HomeController < BaseController
    def index
      featured_templates = Template.with_public_stats.includes(:user).order_by_popularity.limit(3)

      render inertia: "Public/Home", props: {
        hero: hero_content,
        featured_templates: featured_templates.map { |template| template_summary(template) },
        meta: default_meta_tags(
          title: "引越しのやることリスト",
          description: "非ログインでも確認できる公式のやることリストで、引越し前後の段取りを順番に確認できます。"
        )
      }
    end

    private

    def hero_content
      {
        badge: "引越し準備の頼れる相棒",
        title: "何からやればいいか、すぐ分かる",
        lead: "生活インフラの段取りや役所手続きなど、初めての引越しで迷いやすい工程をまとめた公式やることリストです。",
        subcopy: "ダウンロードも会員登録も不要。気になったリストを開いて、手順をひと通り確認できます。",
        cta: {
          href: "/lists",
          label: "公開リストを見る"
        },
        secondary_cta: {
          href: "/signup",
          label: "はじめて使う"
        },
        highlights: [
          "人気のやることリストをそのまま確認",
          "作成者の注意書き付きで安心",
          "気に入ったら自分用にコピーも可能"
        ]
      }
    end
  end
end
