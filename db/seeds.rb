require "securerandom"

# This seed creates minimal data to log in:
# - One Office and one Team
# - One Client under that Team (for initial navigation)
# - One admin user and one employee user (both confirmed)
#
# You can override emails and passwords via env vars:
#   SEED_ADMIN_EMAIL, SEED_ADMIN_PASSWORD
#   SEED_EMPLOYEE_EMAIL, SEED_EMPLOYEE_PASSWORD
ActiveRecord::Base.transaction do
  # Office and Team
  office = Office.find_or_create_by!(name: "デモ事業所")
  team = office.teams.find_or_create_by!(name: "Aチーム")

  # Client (for initial navigation after login)
  client = office.clients.find_or_create_by!(team: team, name: "テスト顧客")

  # Admin user
  admin_email = ENV.fetch("SEED_ADMIN_EMAIL", "kakusikerotan2@gmail.com")
  admin_password = ENV["SEED_ADMIN_PASSWORD"] || SecureRandom.base58(20)

  admin = User.find_or_initialize_by(email: admin_email)
  if admin.new_record?
    admin.assign_attributes(
      name: "管理者",
      office: office,
      team: team,
      role: :admin,
      password: admin_password,
      password_confirmation: admin_password,
      confirmed_at: Time.current
    )
    admin.save!
    puts "[seed] Admin created => #{admin.email} / #{admin_password}"
  else
    puts "[seed] Admin exists   => #{admin.email} / #{admin_password}"
  end

  # Employee user
  employee_emails = [
    ENV.fetch("SEED_EMPLOYEE_EMAIL", "employee1@example.com"),
    ENV.fetch("SEED_EMPLOYEE_EMAIL_2", "employee2@example.com"),
    ENV.fetch("SEED_EMPLOYEE_EMAIL_3", "employee3@example.com"),
    ENV.fetch("SEED_EMPLOYEE_EMAIL_4", "employee4@example.com")
  ]
  employee_names = [ "従業員 太郎", "従業員 次郎", "従業員 三郎", "従業員 四郎" ]
  employee_password = ENV["SEED_EMPLOYEE_PASSWORD"] || SecureRandom.base58(16)

  employee_emails.zip(employee_names).each do |email, name|
    employee = User.find_or_initialize_by(email: email)
    if employee.new_record?
      employee.assign_attributes(
        name: name,
        office: office,
        team: team,
        role: :employee,
        password: employee_password,
        password_confirmation: employee_password,
        confirmed_at: Time.current
      )
      employee.save!
      puts "[seed] Employee created => #{employee.email} / #{employee_password}"
    else
      puts "[seed] Employee exists   => #{employee.email}/ #{employee_password}"
    end
  end

  puts "[seed] Office: #{office.name} (id=#{office.id})"
  puts "[seed] Team:   #{team.name} (id=#{team.id})"
  puts "[seed] Client: #{client.name} (id=#{client.id})"
end
