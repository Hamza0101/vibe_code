class Users::SessionsController < Devise::SessionsController
  protected

  def after_sign_in_path_for(resource)
    merge_guest_cart_to_user(resource)
    if resource.admin?
      admin_root_path
    elsif resource.vendor?
      vendor_root_path
    else
      root_path
    end
  end

  private

  def merge_guest_cart_to_user(user)
    guest_session_id = session[:cart_session_id]
    return if guest_session_id.blank?

    guest_cart = Cart.find_by(session_id: guest_session_id)
    return if guest_cart.nil? || guest_cart.empty?

    user_cart = user.cart || user.create_cart
    user_cart.merge_with(guest_cart)
    session.delete(:cart_session_id)
  end
end
