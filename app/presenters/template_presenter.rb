class TemplatePresenter
  def initialize(template, current_user)
    @template = template
    @current_user = current_user
  end

  def detail
    reviews = @template.template_reviews
    current_user_id = @current_user&.id
    current_review =
      current_user_id && reviews.find { |review| review.user_id == current_user_id }
    current_rating =
      current_user_id &&
        @template.template_ratings.find { |rating| rating.user_id == current_user_id }

    {
      id: @template.id,
      title: @template.title,
      description: @template.description,
      author: {
        name: @template.user.name
      },
      updated_at: @template.updated_at.iso8601,
      average_score: @template.public_average_score,
      ratings_count: @template.public_ratings_count,
      reviews_count: @template.public_reviews_count,
      copies_count: @template.public_copies_count,
      author_notes: @template.author_notes,
      timeline: @template.template_items.map do |item|
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
      current_review: current_review && {
        id: current_review.id,
        content: current_review.content,
        score: current_rating&.score
      },
      cta: {
        message: "自分用にするにはログインしてください。",
        button_label: "ログイン",
        href: "/login"
      }
    }
  end
end
