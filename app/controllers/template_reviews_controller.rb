class TemplateReviewsController < ApplicationController
  rescue_from ActiveRecord::RecordNotUnique, with: :handle_record_not_unique

  before_action :set_template
  before_action :set_review_and_rating, only: %i[update destroy]

  def create
    review = @template.template_reviews.new(
      user: current_user,
      content: review_params[:content]
    )
    rating = current_user.template_ratings.find_or_initialize_by(template: @template)
    rating.score = review_params[:score]

    save_review_and_rating(review: review, rating: rating, notice: "レビューを投稿しました")
  end

  def update
    if @review.nil? && @rating.nil?
      return render_review_errors(base: I18n.t("errors.messages.review_not_found"))
    end

    @review ||= @template.template_reviews.build(user: current_user)
    @review.assign_attributes(content: review_params[:content])
    @rating ||= current_user.template_ratings.build(template: @template)
    @rating.assign_attributes(score: review_params[:score])

    save_review_and_rating(review: @review, rating: @rating, notice: "レビューを更新しました")
  end

  def destroy
    if @review.nil? && @rating.nil?
      return render_review_errors(base: I18n.t("errors.messages.review_not_found"))
    end

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
    presenter = template_presenter
    @review = presenter.current_review
    @rating = presenter.current_rating
  end

  def review_params
    params.require(:template_review).permit(:content, :score)
  end

  def render_review_errors(review: nil, rating: nil, base: nil)
    errors = {}
    all_base_errors = [
      base,
      review&.errors[:base],
      rating&.errors[:base]
    ].flatten.compact.uniq
    errors[:base] = all_base_errors if all_base_errors.present?
    errors.merge!(review.errors.slice(:content)) if review&.errors&.include?(:content)
    errors.merge!(rating.errors.slice(:score)) if rating&.errors&.include?(:score)
    render inertia: "Public/Templates/Show",
           props: public_template_show_props(@template, errors: errors),
           status: :unprocessable_entity
  end

  def save_review_and_rating(review:, rating:, notice:)
    if review.valid? && rating.valid?
      TemplateReview.transaction do
        review.save!
        rating.save!
      end
      redirect_to public_template_path(@template), notice: notice
    else
      render_review_errors(review: review, rating: rating)
    end
  end

  def handle_record_not_unique
    render_review_errors(base: I18n.t("errors.messages.review_or_rating_already_exists"))
  end

  def template_presenter
    @template_presenter ||= TemplatePresenter.new(@template, current_user)
  end
end
