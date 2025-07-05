class PostsController < ApplicationController
  before_action :set_and_authorize_post, only: %i[ show edit update destroy ]

  # GET /posts or /posts.json
  def index
    @user = User.find(params[:user_id])
    @posts = Post.from_user(params[:user_id]).page(params[:p])
  end

  def feed
    @posts = Post.random.page(1)
    render :index
  end

  # GET /posts/1 or /posts/1.json
  def show
    @new_comment = Comment.new(post: @post, user: current_user)
    @comments = @post.comments.order(created_at: :desc)
  end

  # GET /posts/new
  def new
    @post = Post.new
    authorize @post
  end

  # GET /posts/1/edit
  def edit
    @previous_page = @post
  end

  # POST /posts or /posts.json
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

  # PATCH/PUT /posts/1 or /posts/1.json
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

  # DELETE /posts/1 or /posts/1.json
  def destroy
    @post.destroy!

    respond_to do |format|
      format.html { redirect_to posts_path, status: :see_other, notice: "Post was successfully deleted." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_and_authorize_post
      @post = Post.find(params.expect(:id))
      authorize @post
    end

    # Only allow a list of trusted parameters through.
    def post_params
      params.expect(post: [ :title, :body ])
    end
end
