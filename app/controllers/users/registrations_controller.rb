class Users::RegistrationsController < Devise::RegistrationsController
  def new
    @user = User.new
    @user.role = params[:role] || "customer"
    super
  end

  def create
    super do |user|
      if user.vendor? && user.persisted?
        redirect_to edit_vendor_store_path, notice: "Welcome! Please set up your store." and return
      end
    end
  end

  protected

  def after_sign_up_path_for(resource)
    if resource.vendor?
      edit_vendor_store_path
    elsif resource.admin?
      admin_root_path
    else
      root_path
    end
  end

  def after_update_path_for(resource)
    root_path
  end
end
