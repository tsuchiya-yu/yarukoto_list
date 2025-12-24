class TemplateReviewsController < ApplicationController
  before_action :set_template
  before_action :set_review_and_rating, only: %i[update destroy]

  def create
    if current_user.template_reviews.exists?(template: @template)
      return render_review_errors(
        base: I18n.t("errors.messages.review_already_exists")
      )
    end

    review = @template.template_reviews.new(
      user: current_user,
      content: review_params[:content]
    )
    rating = @template.template_ratings.new(
      user: current_user,
      score: review_params[:score]
    )

    if review.valid? && rating.valid?
      TemplateReview.transaction do
        review.save!
        rating.save!
      end
      return redirect_to public_template_path(@template), notice: "レビューを投稿しました"
    end

    render_review_errors(review: review, rating: rating)
  rescue ActiveRecord::RecordNotUnique
    render_review_errors(base: I18n.t("errors.messages.review_already_exists"))
  end

  def update
    if @review.nil?
      return render_review_errors(
        base: "編集するレビューが見つかりませんでした。ページを再読み込みしてください。"
      )
    end

    @review.assign_attributes(content: review_params[:content])
    @rating ||= current_user.template_ratings.build(template: @template)
    @rating.assign_attributes(score: review_params[:score])

    if @review.valid? && @rating.valid?
      TemplateReview.transaction do
        @review.save!
        @rating.save!
      end
      return redirect_to public_template_path(@template), notice: "レビューを更新しました"
    end

    render_review_errors(review: @review, rating: @rating)
  end

  def destroy
    TemplateReview.transaction do
      @review&.destroy!
      @rating&.destroy!
    end

    redirect_to public_template_path(@template), notice: "レビューを削除しました"
  rescue ActiveRecord::RecordNotDestroyed
    render_review_errors(
      base: I18n.t("errors.messages.review_not_destroyed")
    )
  end

  private

  def set_template
    @template =
      Template
      .with_public_stats
      .includes(:user, :template_items, :template_ratings, template_reviews: :user)
      .find(params[:template_id])
  end

  def set_review_and_rating
    @review = current_user.template_reviews.find_by(template: @template)
    @rating = current_user.template_ratings.find_by(template: @template)
  end

  def review_params
    params.require(:template_review).permit(:content, :score)
  end

  def render_review_errors(review: nil, rating: nil, base: nil)
    errors = {}
    errors[:base] = base if base.present?
    if review&.errors&.dig(:content).present?
      errors[:content] = review.errors[:content]
    end
    if rating&.errors&.dig(:score).present?
      errors[:score] = rating.errors[:score]
    end
    render inertia: "Public/Templates/Show",
           props: public_template_show_props(@template, errors: errors),
           status: :unprocessable_entity
  end
end
