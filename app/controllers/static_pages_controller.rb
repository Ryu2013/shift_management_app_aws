class StaticPagesController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[terms privacy_policy how_to_use how_to_use_registration how_to_use_login how_to_use_shift_creation how_to_use_attendance how_to_use_chat specified_commercial_transactions]
  skip_before_action :office_authenticate, only: %i[terms privacy_policy how_to_use how_to_use_registration how_to_use_login how_to_use_shift_creation how_to_use_attendance how_to_use_chat specified_commercial_transactions]
  skip_before_action :user_authenticate, only: %i[terms privacy_policy how_to_use how_to_use_registration how_to_use_login how_to_use_shift_creation how_to_use_attendance how_to_use_chat specified_commercial_transactions]

  def how_to_use
  end

  def how_to_use_registration
  end

  def how_to_use_login
  end

  def how_to_use_shift_creation
  end

  def how_to_use_attendance
  end

  def how_to_use_chat
  end

  def terms
  end

  def privacy_policy
  end

  def specified_commercial_transactions
  end
end
