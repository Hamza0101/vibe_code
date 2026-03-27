class AddressesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_address, only: %i[edit update destroy]

  def index
    @addresses = current_user.addresses.default_first
  end

  def new
    @address = Address.new
  end

  def create
    @address = current_user.addresses.build(address_params)
    @address.is_default = true if current_user.addresses.none?
    if @address.save
      redirect_to addresses_path, notice: "Address saved."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @address.update(address_params)
      redirect_to addresses_path, notice: "Address updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @address.destroy
    redirect_to addresses_path, notice: "Address deleted."
  end

  private

  def set_address
    @address = current_user.addresses.find(params[:id])
  end

  def address_params
    params.require(:address).permit(:line1, :line2, :city, :province, :postal_code, :is_default)
  end
end
