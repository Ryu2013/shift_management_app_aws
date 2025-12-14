class AdminPolicy
  def initialize(user, record)
    @user = user
  end

  def allow?
    @user.admin?
  end
end
