class UsersController < ApplicationController
  before_action :set_and_authorize_user, only: %i[ show edit update remove_avatar ]

  # GET /users or /users.json
  def index
    @users = User.all
  end

  # GET /users/1 or /users/1.json
  def show
    @posts = @user.posts.order(created_at: :desc).page(params[:p])
  end

  # GET /users/1/edit
  def edit
    @previous_page = @user
  end

  # PATCH/PUT /users/1 or /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: "Profile was successfully updated." }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def remove_avatar
    @user.avatar.purge
    redirect_to :edit_user, notice: 'Avatar was successfully removed.'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_and_authorize_user
    @user = User.find(params.expect(:id))
    authorize @user
  end

  # Only allow a list of trusted parameters through.
  def user_params
    params.expect(user: [ :nickname, :avatar ])
  end
end
