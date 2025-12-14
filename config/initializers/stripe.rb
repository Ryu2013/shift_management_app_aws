Rails.configuration.stripe = {
  publishable_key: Rails.application.credentials.dig(:stripe, :public_key),
  secret_key:      Rails.application.credentials.dig(:stripe, :secret_key),
  web_hook_secret: Rails.application.credentials.dig(:stripe, :web_hook_secret)
}

Stripe.api_key = Rails.configuration.stripe[:secret_key]
