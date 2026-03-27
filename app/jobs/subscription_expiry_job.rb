class SubscriptionExpiryJob < ApplicationJob
  queue_as :default

  def perform
    expired_subs = StoreSubscription.active.where("ends_at < ?", Time.current)
    expired_subs.each do |sub|
      sub.update(status: "expired")
      free_plan = SubscriptionPlan.find_by(slug: "free")
      sub.store.update(subscription_plan: free_plan) if free_plan
    end
  end
end
