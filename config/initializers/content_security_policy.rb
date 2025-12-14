Rails.application.configure do
  config.content_security_policy do |p|
    p.default_src :self
    p.script_src  :self, :https, "https://www.googletagmanager.com", "https://www.google-analytics.com"
    p.style_src   :self, :https
    p.img_src     :self, :https, :data, :blob, "https://www.google-analytics.com"
    p.font_src    :self, :https, :data
    p.connect_src :self, :https, "https://www.care-shift.jp", "wss://www.care-shift.jp", "https://www.google-analytics.com", "https://region1.google-analytics.com", "https://www.googletagmanager.com"
    p.object_src  :none
    p.base_uri    :self
    p.frame_ancestors :self
    # p.report_uri "/csp-violation-report-endpoint"
  end
  config.content_security_policy_nonce_generator = ->(request) { SecureRandom.base64(16) }
  config.content_security_policy_nonce_directives = %w[script-src style-src]
  config.content_security_policy_nonce_auto = true
  # config.content_security_policy_report_only = true # ←まずは dev/stg で有効化
end
