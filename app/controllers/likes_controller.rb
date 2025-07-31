class LikesController < ApplicationControlle
  before_action :set_likable_and_like
  before_action :autorize_like

  def create
    respond_to do |format|
      if @like.save
        likableKey = "#{@likable.class.name.downcase}Id".to_sym
        format.html { redirect_to @likable, notice: "#{@likable.class.name} liked" }
        format.json { render json: { likableKey => @likable.id, likesCount: @likable.likes_count, liked: true } }
      else
        format.html { redirect_to @likable, alert: "Unable to like this #{@likable.class.name.downcase}" }
        format.json { render json: { errors: @like.errors, liked: false }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    respond_to do |format|
      if @like.destroy
        likableKey = "#{@likable.class.name.downcase}Id".to_sym
        format.html { redirect_to @likable, notice: "#{@likable.class.name} unliked" }
        format.json { render json: { likableKey => @likable.id, likesCount: @likable.likes_count, liked: false } }
      else
        format.html { redirect_to @likable, alert: 'Unable to remove like' }
        format.json { render json: { errors: @like.errors, liked: true }, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_likable_and_like
    if params[:comment_id]
      @likable = Comment.find(params[:comment_id])
    elsif params[:post_id]
      @likable = Post.find(params[:post_id])
    else
      render json: { errors: ["Object id isn't provided"] }, status: :bad_request
      return
    end

    @like = @likable.likes.find_or_create_by(user: current_user)
  end

  def authorize_like
    authorize @like
  end
end
