class ApplicationController < ActionController::Base
  include Pundit::Authorization
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  allow_browser versions: :modern

  private

  def user_not_authorized
    flash[:alert] = "You don't have permission to complete this action"

    respond_to do |format|
      format.html { redirect_to(request.referrer || root_url) }
      format.json { render status: :unauthorized, json: { errors: "You are not authorized." } }
    end
  end
end
