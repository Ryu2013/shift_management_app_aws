require 'rails_helper'

RSpec.describe "subscriptions/checkout.html.erb", type: :view do
  let(:team) { create(:team) }
  let(:client) { create(:client, team: team, office: team.office) }

  before do
    assign(:team, team)
    assign(:client, client)
  end

  it '成功メッセージと戻りリンクが表示される' do
    render

    expect(rendered).to include("サブスクリプションありがとうございます！")
    expect(rendered).to include("毎月更新日(契約日)に従業員×300円のご請求がございます。")
    expect(rendered).to have_link("ホームに戻る", href: team_client_shifts_path(team, client))
  end
end
