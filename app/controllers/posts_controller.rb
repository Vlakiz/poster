class PostsController < ApplicationController
  before_action :set_and_authorize_post, only: %i[ show edit update destroy ]

  def index
    if params[:user_id]
      filter = { user_id: params[:user_id] }

      @posts = Post.from_user(params[:user_id]).order(published_at: :desc)
    elsif params[:seed_id]
      filter = { seed_id: params[:seed_id] }

      @posts = Post.random(@seed_id)
    end

    @posts = @posts.includes(user: :avatar_attachment).page(params[:page])

    render partial: "posts/posts", locals: { posts: @posts, filter: filter }
  end

  def feed
    @seed_id = rand.round(5)
    @posts = Post.random(@seed_id).includes(user: :avatar_attachment).page(1)
    render :index
  end

  def show
    @new_comment = Comment.new(post: @post, user: current_user)
    @comments_order = params[:corder] || 'rating'
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
    @post.published_at = DateTime.now

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
