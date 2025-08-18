class PostsController < ApplicationController
  before_action :set_and_authorize_post, only: %i[ show edit update destroy ]

  def feed
    @filter = { feed: params[:feed] }

    if params[:user_id]
      user = User.find(params[:user_id])
      return head :not_found unless user

      @filter = { user_id: params[:user_id] }
      @posts = Post.from_user(user).fresh
    elsif params[:feed] == "hot"
      @filter.merge!(seed_id: params[:seed_id] || rand.round(5))
      @posts = Post.random(@filter[:seed_id])
    elsif params[:feed] == "new"
      @posts = Post.fresh
    elsif params[:feed] == "best"
      @posts = Post.best
    elsif params[:feed] == "subscriptions"
      @posts = Post.subscriptions(current_user).fresh
    end

    @posts = @posts.includes_user_like(current_user)
                   .includes(user: :avatar_attachment)
                   .page(params[:page])

    if user_signed_in?
      @posts = @posts.includes(preview_likes: [ user: [ :avatar_attachment ] ])
    end

    render :feed, formats: turbo_frame_request? ? :turbo_stream : :html
  end

  def show
    @new_comment = Comment.new(post: @post, user: current_user)
    @comments_order = params[:corder] || "rating"
    @preview_likes = @post.preview_likes.includes(user: [ :avatar_attachment ])
  end

  def new
    @post = Post.new
    authorize @post
  end

  def edit
    @previous_page = @post
  end

  def create
    @post = Post.new(post_params)
    authorize @post
    @post.user = current_user
    @post.publish!

    respond_to do |format|
      if @post.save
        format.html { redirect_to @post, notice: "Post was successfully created." }
        format.json { render :show, status: :created, location: @post }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @post.update(post_params)
        format.html { redirect_to @post, notice: "Post was successfully updated." }
        format.json { render :show, status: :ok, location: @post }
      else
        @previous_page = @post
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @post.destroy!

    respond_to do |format|
      format.html { redirect_to @post.user, status: :see_other, notice: "Post was successfully deleted." }
      format.json { head :no_content }
    end
  end

  private

  def set_and_authorize_post
    @post = Post.find(params.expect(:id))
    authorize @post
  end

  def post_params
    params.expect(post: [ :title, :body ])
  end
end
