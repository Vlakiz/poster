class CommentsController < ApplicationController
  before_action :set_comment_and_post, only: %i[ show edit update destroy ]
  before_action :authorize_comment, only: %i[ show edit update destroy ]

  def index
    page = params[:page]
    @order = params[:order]
    @post_id = params[:post_id]

    @comments = Post.find(@post_id)
                    .comments.not_replies
                    .includes_user_like(current_user)
                    .includes(user: :avatar_attachment)
                    .page(page)

    if user_signed_in?
      @comments = @comments.includes(preview_likes: [ user: [ :avatar_attachment ] ])
    end

    if @order == "older"
      @comments = @comments.order(created_at: :asc)
    elsif @order == "newer"
      @comments = @comments.order(created_at: :desc)
    else
      @order = "rating"
      @comments = @comments.order(likes_count: :desc, created_at: :desc)
    end

    render :index, formats: @comments.first_page? ? :html : :turbo_stream
  end

  def replies
    @comment_id = params[:comment_id]

    if params[:hide]
      @hide = true
    else
      page = params[:page]
      @replies = Comment.replying_to(params[:comment_id])
                        .includes_user_like(current_user)
                        .includes(user: :avatar_attachment)
                        .page(page).per(5)

      if user_signed_in?
        @replies = @replies.includes(preview_likes: [ user: [ :avatar_attachment ] ])
      end
    end

    render :replies, formats: :turbo_stream
  end

  def show
    @preview_likes = @comment.preview_likes.includes(user: [ :avatar_attachment ])
    render @comment
  end

  def new
    authorize Comment

    if params[:reply_nickname]
      body = "#{params[:reply_nickname]}, "
    end

    @ref_reply_id = params[:ref_reply_id]
    @comment ||= Comment.new(post_id: params.expect(:post_id),
                             replied_to_id: params[:replied_to_id],
                             body: body,)
    render :new, layout: false
  end

  def edit
    @previous_page = @post
    render :edit, layout: false
  end

  def create
    authorize Comment

    @comment = Comment.new(comment_params)
    @comment.user = current_user
    form_frame_id = request.headers["Turbo-Frame"]

    respond_to do |format|
      if @comment.save
        notice = "Comment has been added."
        replied_to_id = @comment.replied_to_id

        format.turbo_stream do
          render :create, locals: { notice: notice,
                                    replied_to_id: replied_to_id,
                                    form_frame_id: form_frame_id }
        end
        format.html { redirect_to post_path(@comment.post, corder: "newer"), notice: notice }
        format.json { render :show, status: :created, location: @comment }
      else
        if turbo_frame_request?
          @ref_reply_id = form_frame_id[/comment_(\d+)_new/, 1]
        end

        format.html { render :new, status: :unprocessable_entity, layout: !turbo_frame_request? }
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
        notice = is_changed ? "Comment has been updated." : nil
        frame_id = request.headers["Turbo-Frame"]

        format.json { render :show, status: :ok, location: @comment }
        format.any { render :update, formats: :turbo_stream,
                            locals: { notice: notice, frame_id: frame_id }  }
      else
        @previous_page = @post
        format.html { render :edit, status: :unprocessable_entity, layout: !turbo_frame_request? }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @comment.destroy!

    respond_to do |format|
      notice = "Comment has been deleted."
      frame_id = request.headers["Turbo-Frame"]
      format.json { head :no_content }
      format.any { render :destroy, formats: :turbo_stream,
                          locals: { notice: notice, frame_id: frame_id } }
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
