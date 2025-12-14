class SubscriptionsController < ApplicationController
  before_action :set_team, only: %i[ checkout ]
  before_action :set_client, only: %i[ checkout ]

  def index
    # サブスク選択画面
  end

  def subscribe
    service = StripeSubscriptionService.new(current_user.office, current_user)
    session_url = service.create_checkout_session(
      success_url: subscriptions_checkout_url,
      cancel_url: subscriptions_index_url
    )
    redirect_to session_url, allow_other_host: true
  end

  def checkout
    # サブスク完了後の画面
  end

  def portal
    # Stripeの顧客ポータルへリダイレクト
    portal_session = Stripe::BillingPortal::Session.create(
      customer: @office.stripe_customer_id,
      return_url: edit_office_url(@office) # ポータルから「戻る」ボタンを押したときの戻り先
    )

    # Stripeの管理画面へ飛ばす
    redirect_to portal_session.url, allow_other_host: true
  end
end
