class LikesController < ApplicationController
  before_action :authorize_user!
  before_action :set_post_and_like

  def create
    respond_to do |format|
      if @like.save
        format.html { redirect_to @post, notice: 'Post liked!' }
        format.json { render :json { post_id: @post.id, likes_count: @post.likes_count, liked: true } }
      else
        format.html { redirect_to @post, alert: 'Unable to like this post' }
        format.json { render json: { errors: @like.errors, liked: false }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    respond_to do |format|
      if @like.destroy
        format.html { redirect_to @post, notice: 'Post unliked' }
        format.json { render :json { post_id: @post.id, likes_count: @post.likes_count, liked: false } }
      else
        format.html { redirect_to @post, alert: 'Unable to remove like' }
        format.json { render json: {errors: @like.errors, liked: true }, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_post_and_like
    @post = Post.find(params[:post_id])
    @like = @post.likes.find_or_create_by(user_id: current_user)
  end
end
