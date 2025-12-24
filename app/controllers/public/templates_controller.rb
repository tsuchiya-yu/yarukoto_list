module Public
  class TemplatesController < BaseController
    SORT_OPTIONS = {
      "popular" => "人気順",
      "rating" => "評価順",
      "newest" => "新着"
    }.freeze
    DEFAULT_SORT = "popular"
    PER_PAGE = 20

    def index
      sort = SORT_OPTIONS.key?(params[:sort]) ? params[:sort] : DEFAULT_SORT
      keyword = params[:q].to_s.strip
      page = normalized_page_param

      templates = Template.with_public_stats.includes(:user)
      templates = apply_keyword_filter(templates, keyword)
      templates = order_for_sort(templates, sort)

      total_count = templates.reselect(nil).count
      total_pages = [((total_count.to_f / PER_PAGE).ceil), 1].max
      page = [page, total_pages].min
      paginated_templates = templates.offset((page - 1) * PER_PAGE).limit(PER_PAGE)
      template_list = paginated_templates.to_a

      render inertia: "Public/Templates/Index", props: {
        templates: template_list.map { |template| template_summary(template) },
        filters: {
          sort: sort,
          keyword: keyword,
          page: page
        },
        pagination: pagination_meta(total_count:, page:, total_pages:),
        sort_options: SORT_OPTIONS.map { |value, label| { value: value, label: label } },
        meta: default_meta_tags(
          title: "公開やることリスト一覧",
          description: helpers.public_list_meta_description(
            sort: sort,
            keyword: keyword,
            sort_options: SORT_OPTIONS,
            default_sort: DEFAULT_SORT
          )
        )
      }
    end

    def show
      template =
        Template
        .with_public_stats
        .includes(:user, :template_items, :template_ratings, template_reviews: :user)
        .find(params[:id])

      render inertia: "Public/Templates/Show", props: public_template_show_props(template)
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
        relation.order_by_rating
      when "newest"
        relation.order_by_newest
      else
        relation.order_by_popularity
      end
    end

    def normalized_page_param
      page_param = params[:page].to_i
      page_param >= 1 ? page_param : 1
    end

    def pagination_meta(total_count:, page:, total_pages:)
      {
        page: page,
        per_page: PER_PAGE,
        total_count: total_count,
        total_pages: total_pages,
        has_prev: page > 1,
        has_next: page < total_pages
      }
    end
  end
end
