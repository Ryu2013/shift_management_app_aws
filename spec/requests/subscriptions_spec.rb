require 'rails_helper'

RSpec.describe "Subscriptions", type: :request do
  include Warden::Test::Helpers
  let(:office) { create(:office) }
  let(:user) { create(:user, office: office, role: :admin) }

  before do
    login_as(user, scope: :user)
    # Mock authentication filters
    allow_any_instance_of(ApplicationController).to receive(:office_authenticate).and_return(true)
    allow_any_instance_of(ApplicationController).to receive(:user_authenticate).and_return(true)
  end

  describe "GET /subscriptions/index" do
    it "returns http success" do
      get subscriptions_index_path
      puts "Response Status: #{response.status}"
      puts "Response Body: #{response.body}" unless response.successful?
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /subscriptions/subscribe" do
    it "redirects to stripe" do
      # Mock Stripe service
      service = instance_double(StripeSubscriptionService)
      allow(StripeSubscriptionService).to receive(:new).and_return(service)
      allow(service).to receive(:create_checkout_session).and_return("https://stripe.com/checkout")

      post subscriptions_subscribe_path
      expect(response).to redirect_to("https://stripe.com/checkout")
    end
  end
end
