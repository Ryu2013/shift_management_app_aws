// Stimulus の Application クラスを @hotwired/stimulus から読み込む
import { Application } from "@hotwired/stimulus"

// Stimulus をアプリケーション全体で起動（必須）
const application = Application.start()

// デバッグログ（controller 接続ログなど）を出すかどうか
// true にすると console に情報が大量に出る
application.debug = false

// Stimulus を window に公開して、ブラウザの console から参照できるようにする
// 例: console で Stimulus.controllers を確認できる
window.Stimulus = application

// 他の JS ファイルから application を import できるようにする
export { application }
