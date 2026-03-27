class ApplicationController < ActionController::Base
  include Pundit::Authorization
  include Pagy::Backend

  before_action :configure_permitted_parameters, if: :devise_controller?

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  helper_method :current_cart

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[name phone role])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[name phone])
  end

  def current_cart
    @current_cart ||= begin
      if user_signed_in?
        current_user.cart || current_user.create_cart
      else
        session[:cart_session_id] ||= SecureRandom.hex(16)
        Cart.find_or_create_by(session_id: session[:cart_session_id])
      end
    end
  end

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_back(fallback_location: root_path)
  end
end
