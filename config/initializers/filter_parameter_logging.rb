# このファイルを変更したらサーバーを再起動してください。
#
# 部分一致でマッチするパラメータ（例: passw は password に一致）を設定し、ログファイルからフィルタします。
# これにより機密情報の漏洩を抑制できます。
# サポートされている表記や動作については ActiveSupport::ParameterFilter のドキュメントを参照してください。
# 例: Parameters: {"email"=>"[FILTERED]", "otp_attempt"=>"[FILTERED]"}
Rails.application.config.filter_parameters += [
  :passw, :email, :secret, :token, :_key, :crypt, :salt, :certificate, :otp, :ssn, :otp_attempt, :cvv, :cvc
]
