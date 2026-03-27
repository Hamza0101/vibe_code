class OrderNotificationJob < ApplicationJob
  queue_as :default

  def perform(order_id, event_type)
    order = Order.find_by(id: order_id)
    return unless order

    case event_type
    when "new_order"
      OrderMailer.new_order_vendor(order).deliver_later
      OrderMailer.order_confirmation_customer(order).deliver_later
    when "status_changed"
      OrderMailer.status_update_customer(order).deliver_later
    end
  end
end
