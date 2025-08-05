class SubscriptionsController < ApplicationController
  before_action :authorize_subscription
  before_action :set_following_user

  # POST /follows or /follows.json
  def create
    subscription = current_user.follow!(@following_user)

    respond_to do |format|
      if subscription.errors.empty?
        format.html { redirect_to @following_user, notice: "You are following #{@following_user.nickname} now" }
        format.json { render json: { following_id: @following_user.id,
                                     followingCount: current_user.following_count,
                                     followed: true }, status: :see_other }
      else
        format.html { redirect_to @following_user, alert: subscription.errors.full_messages.first }
        format.json { render json: { errors: subscription.errors, followed: false }, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /follows/1 or /follows/1.json
  def destroy
    subscription = current_user.unfollow!(@following_user)

    respond_to do |format|
      format.html { redirect_to follows_path, status: :see_other, notice: "Follow was successfully destroyed." }
      format.json { head :no_content }
    end

    respond_to do |format|
      if subscription.errors.empty?
        format.html { redirect_to @following_user,
                                  status: :see_other,
                                  notice: "You are not following #{@following_user.nickname} anymore" }
        format.json { render json: { following_id: @following_user.id,
                                     followingCount: current_user.following_count,
                                     followed: false }, status: :see_other }
      else
        format.html { redirect_to @following_user, alert: subscription.errors.full_messages.first }
        format.json { render json: { errors: subscription.errors, followed: true }, status: :unprocessable_entity }
      end
    end
  end

  private

  def authorize_subscription
    authorize Subscription
  end

  def set_following_user
    @following_user = User.find(params[:user_id])
  end
end
