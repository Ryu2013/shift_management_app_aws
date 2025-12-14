require 'rails_helper'

RSpec.describe "サインイン処理", type: :system do
  describe 'ログイン処理' do
    include ActiveSupport::Testing::TimeHelpers
    let!(:user) { build(:user) }
    let(:password) { 'password123' }

    it '2FA無効のadminでログインできる' do
      user.role = :admin
      user.otp_required_for_login = false
      user.save!
      visit new_user_session_path
      fill_in 'user_email', with: user.email
      fill_in 'user_password', with: password
      click_button 'ログイン'

      expect(page).to have_current_path(new_team_client_path(user.team), ignore_query: true)
    end

    it '2FA無効のemployeeでログインできる' do
      user.role = :employee
      user.otp_required_for_login = false
      user.save!
      visit new_user_session_path
      fill_in 'user_email', with: user.email
      fill_in 'user_password', with: password
      click_button 'ログイン'

      expect(page).to have_current_path(employee_shifts_path, ignore_query: true)
    end

    it '2FA有効のadminでOTP入力してログインできる（1画面）' do
      user.role = :admin
      user.otp_required_for_login = true
      freeze_time = Time.current
      travel_to (freeze_time) do
        user.otp_secret = User.generate_otp_secret
        user.save!
        otp = user.current_otp

        visit new_user_session_path
        fill_in 'user_email', with: user.email
        fill_in 'user_password', with: password
        fill_in 'user_otp_attempt', with: otp
        click_button 'ログイン'

        expect(page).to have_current_path(new_team_client_path(user.team), ignore_query: true)
      end
    end

    it '2FA有効のemployeeでOTP入力してログインできる（1画面）' do
      user.role = :employee
      user.otp_required_for_login = true
      freeze_time = Time.current
      travel_to (freeze_time) do
        user.otp_secret = User.generate_otp_secret
        user.save!
        client = create(:client, team: user.team)
        otp = user.current_otp

        visit new_user_session_path
        fill_in 'user_email', with: user.email
        fill_in 'user_password', with: password
        fill_in 'user_otp_attempt', with: otp
        click_button 'ログイン'
      end

      expect(page).to have_current_path(employee_shifts_path, ignore_query: true)
    end
  end
end
