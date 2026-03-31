class SubscriptionsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_vendor!

  def index
    @plans = SubscriptionPlan.by_price.all
    @current_plan = current_user.store&.active_plan
    @current_subscription = current_user.store&.store_subscriptions&.active&.first
  end

  def create
    plan = SubscriptionPlan.friendly.find(params[:plan_id])
    store = current_user.store

    unless store
      redirect_to edit_vendor_store_path, alert: "Please set up your store before subscribing."
      return
    end

    if plan.free?
      activate_free_plan(plan)
      redirect_to vendor_root_path, notice: "You are now on the Free plan."
      return
    end

    if ENV["STRIPE_SECRET_KEY"].present?
      session = Stripe::Checkout::Session.create(
        payment_method_types: ["card"],
        line_items: [{
          price_data: {
            currency: "pkr",
            product_data: { name: "#{plan.name} Plan - #{store.name}" },
            unit_amount: plan.price_pkr * 100,
            recurring: { interval: "month" }
          },
          quantity: 1
        }],
        mode: "subscription",
        success_url: subscriptions_url + "?session_id={CHECKOUT_SESSION_ID}&plan_id=#{plan.id}",
        cancel_url: subscriptions_url,
        metadata: { store_id: store.id, plan_id: plan.id }
      )
      redirect_to session.url, allow_other_host: true
    else
      # JazzCash/EasyPaisa placeholder
      redirect_to subscriptions_path,
                  notice: "Online payment coming soon. Please contact support to upgrade to #{plan.name}."
    end
  end

  private

  def require_vendor!
    redirect_to root_path, alert: "Vendor access required." unless current_user.vendor?
  end

  def activate_free_plan(plan)
    store = current_user.store
    store.store_subscriptions.active.update_all(status: "cancelled")
    store.store_subscriptions.create!(
      subscription_plan: plan,
      status: "active",
      starts_at: Time.current
    )
    store.update(subscription_plan: plan)
  end
end
