class TemplateReviewsController < ApplicationController
  before_action :set_template
  before_action :set_review_and_rating, only: %i[update destroy]

  def create
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
    render_review_errors(base: I18n.t("errors.messages.review_or_rating_already_exists"))
  end

  def update
    if @review.nil?
      return render_review_errors(
        base: I18n.t("errors.messages.review_not_found")
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
    @template = Template.find_for_public_show(params[:template_id])
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
    base_errors = []
    base_errors << base if base.present?
    base_errors.concat(review.errors[:base]) if review&.errors&.key?(:base)
    base_errors.concat(rating.errors[:base]) if rating&.errors&.key?(:base)
    errors[:base] = base_errors.uniq if base_errors.present?
    errors[:content] = review.errors[:content] if review&.errors&.key?(:content)
    errors[:score] = rating.errors[:score] if rating&.errors&.key?(:score)
    render inertia: "Public/Templates/Show",
           props: public_template_show_props(@template, errors: errors),
           status: :unprocessable_entity
  end
end
