require 'rails_helper'
require 'rake'

RSpec.describe 'stripe:report_usage' do
  before(:all) do
    Rake.application.rake_require 'tasks/stripe'
    Rake::Task.define_task(:environment)
  end

  let(:task) { Rake::Task['stripe:report_usage'] }
  let(:conn) { double('Faraday::Connection') }

  before do
    allow(Faraday).to receive(:new).and_return(conn)
  end

  after do
    task.reenable
  end

  def stub_response(status:, body: {})
    double('Faraday::Response', status: status, body: body)
  end

  def request_double
    Struct.new(:headers, :body).new({}, nil)
  end

  it '200系(200/201/202)なら送信成功としてログを出す' do
    office = create(:office, stripe_customer_id: 'cus_success')
    create_list(:user, 3, office: office)

    allow(conn).to receive(:post) do |url, &block|
      req = request_double
      block.call(req) if block
      expect(url).to eq('https://api.stripe.com/v2/billing/meter_events')
      expect(req.body[:payload][:value]).to eq('3') # ユーザー数が文字列化されることを確認
      stub_response(status: 200, body: {})
    end

    expect { task.invoke }.to output(/送信成功/).to_stdout
    expect(conn).to have_received(:post).once
  end

  it 'duplicate_meter_eventの場合は警告ログにする' do
    office = create(:office, stripe_customer_id: 'cus_duplicate')
    create_list(:user, 1, office: office)

    allow(conn).to receive(:post).and_return(stub_response(status: 400, body: 'duplicate_meter_event'))

    expect { task.invoke }.to output(/既に送信済み/).to_stdout
    expect(conn).to have_received(:post).once
  end

  it 'その他のステータスは送信失敗としてログに出す' do
    office = create(:office, stripe_customer_id: 'cus_fail')
    create_list(:user, 2, office: office)

    allow(conn).to receive(:post).and_return(stub_response(status: 500, body: 'error'))

    expect { task.invoke }.to output(/送信失敗/).to_stdout
    expect(conn).to have_received(:post).once
  end
end
