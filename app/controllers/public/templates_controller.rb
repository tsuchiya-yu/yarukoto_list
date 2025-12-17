module Public
  class TemplatesController < BaseController
    SORT_OPTIONS = {
      "popular" => "人気順",
      "rating" => "評価順",
      "newest" => "新着"
    }.freeze
    DEFAULT_SORT = "popular"

    def index
      sort = SORT_OPTIONS.key?(params[:sort]) ? params[:sort] : DEFAULT_SORT
      keyword = params[:q].to_s.strip

      templates = Template.with_public_stats.includes(:user)
      templates = apply_keyword_filter(templates, keyword)
      templates = order_for_sort(templates, sort)
      template_list = templates.to_a

      render inertia: "Public/Templates/Index", props: {
        templates: template_list.map { |template| template_summary(template) },
        filters: {
          sort: sort,
          keyword: keyword
        },
        sort_options: SORT_OPTIONS.map { |value, label| { value: value, label: label } },
        meta: default_meta_tags(
          title: "公開やることリスト一覧",
          description: meta_description_for_list(sort:, keyword:)
        )
      }
    end

    def show
      template =
        Template
        .with_public_stats
        .includes(:user, :template_items, template_reviews: :user)
        .find(params[:id])

      render inertia: "Public/Templates/Show", props: {
        template: template_detail(template),
        fixed_notice: fixed_notice_text,
        meta: default_meta_tags(
          title: template.title,
          description: meta_description_for_template(template)
        )
      }
    end

    private

    def apply_keyword_filter(relation, keyword)
      return relation if keyword.blank?

      sanitized = ActiveRecord::Base.sanitize_sql_like(keyword)
      relation.where(
        "templates.title ILIKE :keyword OR templates.description ILIKE :keyword",
        keyword: "%#{sanitized}%"
      )
    end

    def order_for_sort(relation, sort)
      case sort
      when "rating"
        relation.order(Arel.sql("average_score DESC"), Arel.sql("ratings_count DESC"), updated_at: :desc)
      when "newest"
        relation.order(created_at: :desc)
      else
        relation.order(Arel.sql("copies_count DESC"), Arel.sql("ratings_count DESC"), updated_at: :desc)
      end
    end

    def template_detail(template)
      reviews = template.template_reviews
      {
        id: template.id,
        title: template.title,
        description: template.description,
        author: {
          name: template.user.name
        },
        updated_at: template.updated_at.iso8601,
        average_score: template.public_average_score,
        ratings_count: template.public_ratings_count,
        reviews_count: template.public_reviews_count,
        copies_count: template.public_copies_count,
        author_notes: template.author_notes,
        timeline: template.template_items.map do |item|
          {
            id: item.id,
            title: item.title,
            description: item.description
          }
        end,
        reviews: reviews.map do |review|
          {
            id: review.id,
            user_name: review.user.name,
            content: review.content,
            created_at: review.created_at.iso8601
          }
        end,
        cta: {
          message: "自分用にするにはログインしてください。",
          button_label: "ログインする",
          href: "/login"
        }
      }
    end

    def meta_description_for_list(sort:, keyword:)
      sort_label = SORT_OPTIONS.fetch(sort, SORT_OPTIONS[DEFAULT_SORT])
      base = "引越しのやることリストを#{sort_label}で並べ替えて確認できます。"
      if keyword.present?
        %(#{base} キーワード「#{keyword}」に合致するリストだけを表示中です。)
      else
        %(#{base} 気になるリストを開いて詳細とレビューをチェックできます。)
      end
    end

    def meta_description_for_template(template)
      view_context.truncate(template.description, length: 120)
    end
  end
end
