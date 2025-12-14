require 'rails_helper'

RSpec.describe "権限管理", type: :system do
    let(:password) { 'password123' }
    let!(:office) { create(:office) }
    let!(:team) { create(:team, office: office) }
    let!(:client) { create(:client, team: team, office: office) }

    let!(:admin_user) do
        create(:user,
            email: 'admin@example.com',
            password: password,
            password_confirmation: password,
            role: :admin,
            office: office,
            team: team,
            otp_required_for_login: false
        )
    end

    let!(:employee_user) do
        create(:user,
            email: 'employee@example.com',
            password: password,
            password_confirmation: password,
            role: :employee,
            office: office,
            team: team,
            otp_required_for_login: false
        )
    end

    describe 'Admin権限の確認' do
        before do
            visit new_user_session_path
            fill_in 'user_email', with: admin_user.email
            fill_in 'user_password', with: password
            click_button 'ログイン'
            expect(page).to have_content 'ログインしました'
        end

        it 'adminはシフト一覧にアクセスできる' do
            visit team_client_shifts_path(team, client)
            expect(page).to have_current_path(team_client_shifts_path(team, client))
        end

        it 'adminは顧客一覧にアクセスできる' do
            visit team_clients_path(team)
            expect(page).to have_content '顧客を追加'
            expect(page).to have_current_path(team_clients_path(team))
        end

        it 'adminは従業員一覧にアクセスできる' do
            visit team_users_path(team)
            expect(page).to have_current_path(team_users_path(team))
        end

        it 'adminは出勤状況確認にアクセスできる' do
            visit team_work_statuses_path(team)
            expect(page).to have_current_path(team_work_statuses_path(team))
        end
    end

    describe 'Employee権限の制限' do
        before do
            visit new_user_session_path
            fill_in 'user_email', with: employee_user.email
            fill_in 'user_password', with: password
            click_button 'ログイン'
            expect(page).to have_content 'ログインしました'
        end

        it 'employeeはシフト一覧にアクセスしようとすると従業員用シフトページにリダイレクトされる' do
            visit team_client_shifts_path(team, client)
            expect(page).to have_current_path(employee_shifts_path)
        end

        it 'employeeは顧客一覧にアクセスしようとすると従業員用シフトページにリダイレクトされる' do
            visit team_clients_path(team)
            expect(page).to have_current_path(employee_shifts_path)
        end

        it 'employeeは従業員一覧にアクセスしようとすると従業員用シフトページにリダイレクトされる' do
            visit team_users_path(team)
            expect(page).to have_current_path(employee_shifts_path)
        end

        it 'employeeは出勤状況確認にアクセスしようとすると従業員用シフトページにリダイレクトされる' do
            visit team_work_statuses_path(team)
            expect(page).to have_current_path(employee_shifts_path)
        end

        it 'employeeは従業員用シフトページにアクセスできる' do
            visit employee_shifts_path
            expect(page).to have_current_path(employee_shifts_path)
        end
    end
end
