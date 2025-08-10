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

  def replies
    page = params[:page]
    @comments = Comment.replying_to(params[:comment_id]).page(page, per_page: 5)
  end

  def show
    render @comment
  end

  def new
    authorize Comment

    if params[:reply_nickname]
      body = "#{params[:reply_nickname]}, "
    end
    @comment = Comment.new(post_id: params.expect(:post_id), replied_to_id: params[:replied_to_id], body: body)
    render :new, layout: false
  end

  def edit
    @previous_page = @post
  end

  def create
    authorize Comment

    @comment = Comment.new(comment_params)
    @comment.user = current_user

    respond_to do |format|
      if @comment.save
        if turbo_frame_request? && @comment.replied_to_id
          replied_to_id = @comment.replied_to_id
          flash.now[:notice] = "Comment has been added."
          format.html do
            render partial: "shared/empty_frame",
                   locals: { frame_id: "comment_#{replied_to_id}_new_reply_frame" },
                   notice: notice
          end
        else
          format.html { redirect_to @comment.post, notice: notice }
        end
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

        format.html { redirect_to comment_path, notice: is_changed ? "Comment has been updated." : nil }
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
    @post = Post.find(params[:post_id]) if params[:post_id]
  end

  def authorize_comment
    authorize @comment
  end

  def comment_params
    params.expect(comment: [ :body, :post_id, :replied_to_id ])
  end
end
