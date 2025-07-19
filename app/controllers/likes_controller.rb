class LikesController < ApplicationController
  before_action :authorize_user!
  before_action :set_post_and_like

  def create
    respond_to do |format|
      if @like.save
        format.html { redirect_to @post, notice: 'Post liked!' }
        format.json { render json: { postId: @post.id, likesCount: @post.likes_count, liked: true } }
      else
        format.html { redirect_to @post, alert: "Unable to like this post:\n #{@like.errors.full_messages.join("\n")}" }
        format.json { render json: { errors: @like.errors, liked: false }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    respond_to do |format|
      if @like.destroy
        format.html { redirect_to @post, notice: 'Post unliked' }
        format.json { render json: { postId: @post.id, likesCount: @post.likes_count, liked: false } }
      else
        format.html { redirect_to @post, alert: 'Unable to remove like' }
        format.json { render json: {errors: @like.errors, liked: true }, status: :unprocessable_entity }
      end
    end
  end

  private

  def authorize_user!
    return user_not_authorized unless user_signed_in?
  end

  def set_post_and_like
    @post = Post.find(params[:post_id])
    @like = @post.likes.find_or_create_by(user: current_user)
  end
end
