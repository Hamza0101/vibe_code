class ReviewsController < ApplicationController
  before_action :authenticate_user!

  def create
    reviewable = find_reviewable
    @review = reviewable.reviews.build(review_params.merge(user: current_user, approved: true))

    if @review.save
      redirect_back fallback_location: root_path, notice: "Review submitted."
    else
      redirect_back fallback_location: root_path, alert: @review.errors.full_messages.to_sentence
    end
  end

  def destroy
    @review = current_user.reviews.find(params[:id])
    @review.destroy
    redirect_back fallback_location: root_path, notice: "Review deleted."
  end

  private

  def find_reviewable
    if params[:store_id]
      Store.friendly.find(params[:store_id])
    elsif params[:product_id]
      Product.friendly.find(params[:product_id])
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def review_params
    params.require(:review).permit(:rating, :body)
  end
end
