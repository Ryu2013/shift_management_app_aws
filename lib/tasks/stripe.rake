namespace :stripe do
  desc "全オフィスの従業員数をStripe Meters V2に送信する"
  task report_usage: :environment do
    require "faraday"
    require "json"

    # --- 設定 ---
    EVENT_NAME = "office_seat_update"
    API_URL = "https://api.stripe.com/v2/billing/meter_events"

    puts "--- [開始] Stripe Meters V2 人数同期 ---"

    offices = Office.where.not(stripe_customer_id: nil).preload(:users)

    puts "対象オフィス数: #{offices.count}件"

    # Faradayコネクション作成
    conn = Faraday.new do |f|
      f.request :json
      f.response :json
      f.adapter Faraday.default_adapter
    end

    offices.find_each do |office|
      begin
        current_count = office.users.count

        event_id = "seat_sync_#{Time.current.strftime('%Y%m%d')}_#{office.id}"

        body = {
          event_name: EVENT_NAME,
          payload: {
            stripe_customer_id: office.stripe_customer_id,
            value: current_count.to_s
          },
          identifier: event_id,
          timestamp: Time.current.iso8601
        }

        response = conn.post(API_URL) do |req|
          req.headers["Authorization"] = "Bearer #{Stripe.api_key}"
          req.headers["Content-Type"] = "application/json"
          req.headers["Stripe-Version"] = "2025-11-17.clover"

          req.body = body
        end

        # ★修正: 200 も成功リストに追加
        if [ 200, 201, 202 ].include?(response.status)
          puts "Office ID: #{office.id} -> #{current_count}名 (送信成功)"
        elsif response.status == 400 && response.body.to_s.include?("duplicate_meter_event")
          # 400エラーだけど、重複ならOKとする
          puts "⚠️ Office ID: #{office.id} -> 本日分は既に送信済みです (スキップ)"
        else
          puts "❌ [送信失敗] Office ID: #{office.id} Status: #{response.status} Body: #{response.body}"
        end

      rescue => e
        puts "❌ [例外発生] Office ID: #{office.id} #{e.message}"
        next
      end
    end

    puts "--- [終了] Stripe Meters V2 人数同期 ---"
  end
end
