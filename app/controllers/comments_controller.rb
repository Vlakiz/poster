class CommentsController < ApplicationController
  before_action :set_comment_and_post, only: %i[ show edit update destroy ]
  before_action :authorize_comment, only: %i[ show edit update destroy ]

  def index
    page = params[:page]
    @order = params[:order]
    @post_id = params[:post_id]

    @comments = Post.find(@post_id)
                    .comments.not_replies
                    .includes(user: :avatar_attachment)
                    .page(page)

    if @order == "older"
      @comments = @comments.order(created_at: :asc)
    elsif @order == "newer"
      @comments = @comments.order(created_at: :desc)
    else
      @order = "rating"
      @comments = @comments.order(likes_count: :desc, created_at: :desc)
    end

    render partial: "comments/comments", locals: { comments: @comments, post_id: @post_id, order: @order }
  end

  def show
    render @comment
  end

  def new
    @comment = Comment.new
  end

  def edit
    @previous_page = @post
  end

  def create
    @comment = Comment.new(comment_params)
    @comment.user = current_user

    respond_to do |format|
      if @comment.save
        format.html { redirect_to @comment.post, notice: "Comment has been added." }
        format.json { render :show, status: :created, location: @comment }
      else
        @post = @comment.post
        @new_comment = @comment
        @comments = @post.comments.order(created_at: :desc)

        format.html { render "posts/show", status: :unprocessable_entity }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    previous_update = @comment.updated_at
    respond_to do |format|
      if @comment.update(comment_params)
        current_update = @comment.updated_at
        is_changed = previous_update != current_update

        format.html { redirect_to post_comment_path(post_id: @comment.post_id),
                                  notice: is_changed ? "Comment has been updated." : nil }
        format.json { render :show, status: :ok, location: @comment }
      else
        @previous_page = @post
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @comment.destroy!

    respond_to do |format|
      format.html { redirect_to @comment.post, status: :see_other, notice: "Comment has been deleted." }
      format.json { head :no_content }
    end
  end

  private

  def set_comment_and_post
    @comment = Comment.find(params.expect(:id))
    @post = @comment.post
  end

  def authorize_comment
    authorize @comment
  end

  def comment_params
    params.expect(comment: [ :body, :post_id ])
  end
end
