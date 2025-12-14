require 'rails_helper'
require 'uri'

RSpec.describe '招待フロー', type: :system do
  include LoginMacros
  ActiveJob::Base.queue_adapter = :inline

  let(:password) { 'password123' }

  before do
    ActiveJob::Base.queue_adapter = :inline
  end

  it 'adminが従業員を招待し、招待されたユーザーが受諾してパスワード設定・ログインできる' do
    # 管理者でログイン
    team  = create(:team)
    # 招待送信後に UsersController#index に遷移するため、set_client が動作するよう
    # 少なくとも1件のクライアントを事前に作成しておく
    create(:client, office: team.office, team: team)
    admin = create(:user, role: :admin, team: team, office: team.office,
                     password: password, password_confirmation: password)

    # UI経由でログインして session[:office_id] を確実にセット
    visit new_user_session_path
    fill_in 'user_email', with: admin.email
    fill_in 'user_password', with: password
    click_button 'ログイン'
    expect(page).to have_content 'ログインしました'
    # 招待画面へ
    visit new_user_invitation_path

    expect(page).to have_text('招待を送信', wait: 10)
    # idベースで確実に入力
    fill_in 'user_name', with: "新しいユーザー"
    fill_in 'user_email', with: "test2@example.com"
    find('#user_team_id').find("option[value='#{team.id}']").select_option
    fill_in 'user_address', with: '東京都港区'

    ActiveJob::Base.queue_adapter = :inline

    click_button '招待を送信する'
    expect(page).to have_text('招待メールを', wait: 10)

    mail = nil
    Timeout.timeout(5) do
      loop do
        mail = ActionMailer::Base.deliveries.last
        break if mail.present?
        sleep 0.1 # 0.1秒待って再確認
      end
    end


    body = if mail.multipart?
      (mail.html_part&.decoded || mail.text_part&.decoded || mail.body&.decoded)
    else
      mail.body&.decoded
    end
    body = body.to_s

    # 絶対URLを抽出（改行を含む場合を考慮）
    candidates = URI.extract(body.gsub(/\r?\n/, ''), %w[http https])
    absolute = candidates.find { |u| u.include?("/users/invitation/accept") } || candidates.first

    expect(absolute).to be_present
    path = URI.parse(absolute).request_uri
    reset_session!

    visit path
    # パスワード設定フォームが表示されるまで待機

    expect(page).to have_button('パスワードを設定する', wait: 10)
    # パスワードフィールドに入力
    fill_in 'user_password', with: password
    fill_in 'user_password_confirmation', with: password
    # パスワードを設定するボタンをクリック
    click_button 'パスワードを設定する'
    # 招待受諾後は employee_shifts_path にリダイレクトされる
    expect(page).to have_current_path(employee_shifts_path, ignore_query: true, wait: 10)
  end
end
