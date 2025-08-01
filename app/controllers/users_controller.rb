class UsersController < ApplicationController
  before_action :set_and_authorize_user, except: [ :new_profile, :create_profile ]

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

  def new_profile
    authorize User

    set_countries
  end

  def create_profile
    authorize User

    respond_to do |format|
      if current_user.update(new_profile_params.merge(visible: true))
        format.html { redirect_to current_user, notice: "Profile was successfully created." }
        format.json { render json: {}, status: :ok }
      else
        set_countries
        format.html { render :new_profile, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_countries
    @countries = ISO3166::Country.all
      .map { |country| [ country.common_name, country.alpha2 ] }
      .sort_by(&:first)
  end

  def set_and_authorize_user
    @user = User.find(params.expect(:id))
    authorize @user
  end

  def user_params
    params.expect(user: [ :nickname, :avatar ])
  end

  def new_profile_params
    params.expect(user: [ :first_name, :last_name, :country, :date_of_birth ])
  end
end
