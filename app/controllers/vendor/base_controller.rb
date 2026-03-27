class Vendor::BaseController < ApplicationController
  layout "vendor"

  before_action :authenticate_user!
  before_action :require_vendor!

  helper_method :current_store

  private

  def require_vendor!
    unless current_user&.vendor? || current_user&.admin?
      flash[:alert] = "Vendor access required."
      redirect_to root_path
    end
  end

  def current_store
    @current_store ||= current_user.store
  end

  def require_store!
    unless current_store
      flash[:notice] = "Please set up your store first."
      redirect_to edit_vendor_store_path
    end
  end
end
