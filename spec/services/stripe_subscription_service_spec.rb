require 'rails_helper'

RSpec.describe StripeSubscriptionService do
  let(:user) { create(:user) }
  let(:service) { described_class.new(office, user) }
  let(:success_url) { 'https://example.com/success' }
  let(:cancel_url) { 'https://example.com/cancel' }
  let(:price_id) { 'price_test_123' }
  let(:session_url) { 'https://checkout.stripe.com/test-session' }
  let(:session_double) { instance_double(Stripe::Checkout::Session, url: session_url) }

  around do |example|
    original = ENV['STRIPE_METERED_PRICE_ID']
    ENV['STRIPE_METERED_PRICE_ID'] = price_id
    example.run
    ENV['STRIPE_METERED_PRICE_ID'] = original
  end

  before do
    allow(Stripe::Checkout::Session).to receive(:create).and_return(session_double)
  end

  describe '#create_checkout_session' do
    context 'stripe_customer_id が設定済みの場合' do
      let(:office) { create(:office, stripe_customer_id: 'cus_existing') }

      it '既存の顧客を使ってチェックアウトセッションを作成し、URLを返す' do
        expect(Stripe::Customer).not_to receive(:create)

        result = service.create_checkout_session(success_url: success_url, cancel_url: cancel_url)

        expect(result).to eq(session_url)
        expect(Stripe::Checkout::Session).to have_received(:create).with(
          customer: 'cus_existing',
          mode: 'subscription',
          line_items: [ { price: price_id } ],
          success_url: success_url,
          cancel_url: cancel_url,
          metadata: { office_id: office.id },
          subscription_data: { metadata: { office_id: office.id } }
        )
      end
    end

    context 'stripe_customer_id が未設定の場合' do
      let(:office) { create(:office, stripe_customer_id: nil, name: 'サブスク用オフィス') }
      let!(:user) { create(:user, office: office, email: 'owner@example.com') }
      let(:stripe_customer) { instance_double(Stripe::Customer, id: 'cus_new') }

      before do
        allow(Stripe::Customer).to receive(:create).and_return(stripe_customer)
      end

      it 'Stripe顧客を作成してOfficeに保存し、その顧客でチェックアウトセッションを作成する' do
        result = service.create_checkout_session(success_url: success_url, cancel_url: cancel_url)

        expect(result).to eq(session_url)
        expect(Stripe::Customer).to have_received(:create).with(
          email: user.email,
          name: office.name,
          metadata: { office_id: office.id }
        )
        expect(office.reload.stripe_customer_id).to eq('cus_new')
        expect(Stripe::Checkout::Session).to have_received(:create).with(hash_including(
          customer: 'cus_new',
          mode: 'subscription',
          line_items: [ { price: price_id } ],
          success_url: success_url,
          cancel_url: cancel_url,
          metadata: { office_id: office.id },
          subscription_data: { metadata: { office_id: office.id } }
        ))
      end
    end
  end
end
