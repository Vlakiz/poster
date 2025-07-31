class UsersController < ApplicationController
  before_action :set_and_authorize_user

  def show
    @posts = @user.posts.order(published_at: :desc).includes(user: :avatar_attachment).page(params[:p])
    @country_name = ISO3166::Country.find_country_by_alpha2(@user.country).common_name
  end

  def edit
    @previous_page = @user
  end

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
    redirect_to :edit_user, notice: "Avatar was successfully removed."
  end

  private

  def set_and_authorize_user
    @user = User.find(params.expect(:id))
    authorize @user
  end

  def user_params
    params.expect(user: [ :nickname, :avatar ])
  end
end
