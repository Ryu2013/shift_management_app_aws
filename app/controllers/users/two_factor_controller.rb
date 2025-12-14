class Users::TwoFactorController < ApplicationController
  before_action :authenticate_user!, only: %i[setup confirm]
  before_action :ensure_secret_key!, only: %i[setup confirm]
  skip_before_action :user_authenticate

  # 二段階認証の有効化画面表示
  def setup
    if current_user.admin?
    @team = @office.teams.joins(:clients).distinct.order(:id).first
    @client = @team.clients.order(:id).first
    end
  end

  # 二段階認証の有効化確認処理
  def confirm
    user = current_user
    # device-two-factorGEMのotp_provisioning_uriメソッドで確認コードを検証
    if user.validate_and_consume_otp!(params[:otp_attempt])
        user.update(
            otp_required_for_login: true,
            otp_secret: session.delete(:pending_otp_secret)
        )
      redirect_to root_path
    else
      @team = @office.teams.joins(:clients).distinct.order(:id).first
      @client = @team.clients.order(:id).first
      flash.now[:alert] = t("users.two_factor.invalid_code")
      ensure_secret_key!
      render :setup, status: :unprocessable_entity, formats: [ :html ]
    end
  end

  private

  def ensure_secret_key!
    session[:pending_otp_secret] ||= current_user.otp_secret.presence || User.generate_otp_secret
    current_user.otp_secret = session[:pending_otp_secret]
    @secret_key = current_user.otp_secret
    # device-two-factorGEMのotp_provisioning_uriメソッドでotpauthを生成
    # otpauth://totp/MyApp:user@example.com?secret=ABC123&issuer=MyApp
    otp_uri = current_user.otp_provisioning_uri(current_user.email, issuer: "ShiftManagement")
    # rqrcodeGEMでQRコードをSVG形式で生成。スタンドアローンで親タグ付き。
    @qr_svg = RQRCode::QRCode.new(otp_uri).as_svg(module_size: 3, standalone: true)
  end
end
