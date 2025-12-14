class Users::InvitationsController < Devise::InvitationsController
  include Pundit::Authorization
  before_action :configure_permitted_parameters, only: [ :create ]
  before_action :office_authenticate, only: [ :new, :create ]
  before_action :office_authenticate, only: [ :new, :create ]
  before_action :user_authenticate, only: [ :new, :create ]
  before_action :check_user_limit, only: [ :create ]

  private

  def check_user_limit
    return unless current_user&.office

    current_count = current_user.office.users.count
    puts "🍌🍌🍌: #{current_count}"
    if current_count >= 5 && !current_user.office.subscription_active?
      flash[:alert] = "無料プランの上限（5名）に達しました。メンバーを追加するにはサブスクリプション登録が必要です。"
      redirect_to subscriptions_index_path and return
    end
  end

  protected

  # Strong Parametersの設定
  # ここでフォームから送信されるカスタム属性を許可します
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:invite, keys: [ :name, :team_id, :address ])
  end

  # ここでは、フォームに含まれない「サーバー側で強制的に決める値」だけをマージします
  def invite_params
    # superの時点で name や address は既に許可されているため、
    # 個別に params[:user][:name] などと書く必要がなくなります。
    super.merge(
      office_id: @office.id,
      role: User.roles[:employee]
    )
  end

  def office_authenticate
    sess = session[:office_id]
    if sess.blank? || sess != current_user.office_id
      session.delete(:office_id)
      redirect_to root_path, alert: "事業所情報が不明です" and return
    end
    @office = Office.find_by(id: session[:office_id])
  end

  def user_authenticate
    authorize :admin, :allow?
  rescue Pundit::NotAuthorizedError
    # 直前のフラッシュ（例: Deviseの「ログインしました。」）が残っているケースを排除
    flash.clear
    redirect_to employee_shifts_path, alert: "権限がありません" and return
  end

  def after_invite_path_for(inviter, invitee)
    team_users_path(@office.teams.order(:id).first)
  end

  # 　招待メールのリンクからパスワードを設定した後のリダイレクト先をオーバーライド
  def after_accept_path_for(resource)
    session[:office_id] = resource.office_id
    after_sign_in_path_for(resource)
  end
end
