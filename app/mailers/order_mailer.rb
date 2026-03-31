class OrderMailer < ApplicationMailer
  def new_order_vendor(order)
    @order = order
    @store = order.store
    @vendor = @store.user
    mail(to: @vendor.email, subject: "New Order ##{@order.order_number} received!")
  end

  def order_confirmation_customer(order)
    @order = order
    @customer = order.user
    return unless @customer&.email.present?
    mail(to: @customer.email, subject: "Your order ##{@order.order_number} is confirmed")
  end

  def status_update_customer(order)
    @order = order
    @customer = order.user
    return unless @customer&.email.present?
    mail(to: @customer.email, subject: "Order ##{@order.order_number} status: #{@order.status.humanize}")
  end
end
