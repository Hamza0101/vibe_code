class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def stripe
    payload = request.body.read
    sig_header = request.env["HTTP_STRIPE_SIGNATURE"]
    endpoint_secret = ENV["STRIPE_WEBHOOK_SECRET"]

    begin
      event = Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)
    rescue JSON::ParserError, Stripe::SignatureVerificationError => e
      render json: { error: e.message }, status: :bad_request
      return
    end

    case event.type
    when "checkout.session.completed"
      handle_checkout_completed(event.data.object)
    when "customer.subscription.deleted"
      handle_subscription_cancelled(event.data.object)
    end

    render json: { received: true }
  end

  private

  def handle_checkout_completed(session)
    store_id = session.metadata["store_id"]
    plan_id = session.metadata["plan_id"]
    return unless store_id && plan_id

    store = Store.find_by(id: store_id)
    plan = SubscriptionPlan.find_by(id: plan_id)
    return unless store && plan

    store.store_subscriptions.active.update_all(status: "cancelled")
    store.store_subscriptions.create!(
      subscription_plan: plan,
      stripe_subscription_id: session.subscription,
      status: "active",
      starts_at: Time.current,
      ends_at: 1.month.from_now
    )
    store.update(subscription_plan: plan)
  end

  def handle_subscription_cancelled(subscription)
    sub = StoreSubscription.find_by(stripe_subscription_id: subscription.id)
    return unless sub
    sub.update(status: "cancelled")
    free_plan = SubscriptionPlan.find_by(slug: "free")
    sub.store.update(subscription_plan: free_plan) if free_plan
  end
end
