class CommentsController < ApplicationController
  before_action :set_comment_and_post, only: %i[ show edit update destroy ]
  before_action :authorize_comment, only: %i[ show edit update destroy ]

  # GET /comments or /comments.json
  def index
    @comments = Comment.all
  end

  # GET /comments/1 or /comments/1.json
  def show
  end

  # GET /comments/new
  def new
    @comment = Comment.new
  end

  # GET /comments/1/edit
  def edit
    @previous_page = @post
  end

  # POST /comments or /comments.json
  def create
    @comment = Comment.new(comment_params)
    @comment.user = current_user

    respond_to do |format|
      if @comment.save
        format.html { redirect_to @comment.post, notice: "Comment was added." }
        format.json { render :show, status: :created, location: @comment }
      else
        @post = @comment.post
        @new_comment = @comment
        @comments = @post.comments.order(created_at: :desc)

        format.html { render 'posts/show', status: :unprocessable_entity }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /comments/1 or /comments/1.json
  def update
    respond_to do |format|
      if @comment.update(comment_params)
        format.html { redirect_to @comment.post, notice: "Comment was updated." }
        format.json { render :show, status: :ok, location: @comment }
      else
        @previous_page = @post
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /comments/1 or /comments/1.json
  def destroy
    @comment.destroy!

    respond_to do |format|
      format.html { redirect_to @comment.post, status: :see_other, notice: "Comment was deleted." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_comment_and_post
      @comment = Comment.find(params.expect(:id))
      @post = @comment.post
    end

    def authorize_comment
      authorize @comment
    end

    # Only allow a list of trusted parameters through.
    def comment_params
      params.expect(comment: [ :body, :post_id ])
    end
end
