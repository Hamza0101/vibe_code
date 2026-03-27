class Admin::SubscriptionPlansController < Admin::BaseController
  before_action :set_plan, only: %i[show edit update destroy]

  def index
    @plans = SubscriptionPlan.by_price.all
  end

  def new
    @plan = SubscriptionPlan.new
  end

  def create
    @plan = SubscriptionPlan.new(plan_params)
    if @plan.save
      redirect_to admin_subscription_plans_path, notice: "Plan created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @plan.update(plan_params)
      redirect_to admin_subscription_plans_path, notice: "Plan updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @plan.destroy
    redirect_to admin_subscription_plans_path, notice: "Plan deleted."
  end

  private

  def set_plan
    @plan = SubscriptionPlan.friendly.find(params[:id])
  end

  def plan_params
    params.require(:subscription_plan).permit(:name, :price_pkr, :product_limit, features: {})
  end
end
