require 'rails_helper'

RSpec.describe "subscriptions/index.html.erb", type: :view do
  it 'プラン名と特徴が表示される' do
    render

    expect(rendered).to include("プラン選択")
    expect(rendered).to include("無料プラン")
    expect(rendered).to include("スタンダードプラン")
    expect(rendered).to include("¥0")
    expect(rendered).to include("¥300")
  end

  it '有料プランの申込みボタンがStripe決済POSTになる' do
    render

    expect(rendered).to have_selector("form[action='#{subscriptions_subscribe_path}'][method='post']")
    expect(rendered).to include("Stripeで決済する")
  end
end
