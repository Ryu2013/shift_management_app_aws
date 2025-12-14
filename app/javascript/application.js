// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"
document.addEventListener("turbo:load", () => {
  const fake = document.getElementById("fake-month");
  const real = document.getElementById("real-month");

  // シフト一覧ページの月選択カスタマイズ処理
  if (fake && real) {
  fake.onclick = () => real.showPicker();

  real.onchange = () => {
    const [y, m] = real.value.split("-");
    fake.textContent = `${m}月`;
    real.form.requestSubmit();
  };
  };
  
});


// シフト個別変更フォームの表示処理
// turbo:frame-loadで発火させることで、turbo frame内の要素に対応
document.addEventListener("turbo:frame-load", () => {
const btn = document.getElementById("shift-form-btn");
const form = document.getElementById("shift-form");
const deleteBtn = document.getElementById("shift-form-delete");
if (btn && form && deleteBtn) {
btn.addEventListener("click", () => {
  form.classList.toggle("open");
  deleteBtn.classList.toggle("open");
});
}
});

// ハンバーガーメニューの表示処理
document.addEventListener("turbo:load", () => {
const hamburger = document.getElementById("hamburger");
const pcNav = document.querySelector(".menus");
if (hamburger && pcNav) {
hamburger.addEventListener("click", () => {
  pcNav.classList.toggle("open-menus");
});
}
});

//出勤状況確認ページの日付選択の見た目が気に入らないのでカスタマイズ
// 日付選択用のカレンダーピッカー表示
document.addEventListener("turbo:load", () => {
const fakeDate = document.getElementById("fake-date");
const realDate = document.getElementById("real-date");
if (fakeDate && realDate) {
  fakeDate.onclick = () => realDate.showPicker();

  realDate.onchange = () => {
    const [y, m, d] = realDate.value.split("-");
    fakeDate.textContent = `${y}年${m}月${d}日`;
    realDate.form.requestSubmit();
  };
}
});



document.addEventListener("turbo:load",() => {
  const targets = document.querySelectorAll('.scroll-trigger');

  if (targets.length === 0) return;

  const options = {
    root: null,
    rootMargin: '0px 0px -10% 0px', // 画面の下10%に入ったら発火
    threshold: 0
  };

  const observer = new IntersectionObserver((entries, obs) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add('is-visible');
        obs.unobserve(entry.target);
      }
    });
  }, options);

  targets.forEach(target => observer.observe(target));
});

// ▼ 一番下にスクロールさせる関数
function scrollToBottom() {
  const messages = document.getElementById("messages");
  // IDが 'messages' の要素がある時だけ実行（エラー防止）
  if (messages) { 
    messages.scrollTop = messages.scrollHeight;
  }
}

// 1. 画面が表示された瞬間に実行（Turboのページ移動に対応）
document.addEventListener("turbo:load", () => {
  scrollToBottom();

  // 2. リアルタイム更新の監視（MutationObserverという標準機能を使います）
  const messages = document.getElementById("messages");
  if (messages) {
    const observer = new MutationObserver(() => {
      scrollToBottom();
    });
    // メッセージエリアの中身が増えたら検知してスクロール
    observer.observe(messages, { childList: true, subtree: true });
  }
});

document.addEventListener("turbo:load", () => {
  const currentUserId = document.body.dataset.currentUserId
  if (!currentUserId) return
  const messageUserId = document.body.dataset.messageUserId
  if (!messageUserId || messageUserId !== currentUserId) return

  const message = document.getElementById("message");
  const messageName = document.getElementById("message-name");
  const messageIcon = document.getElementById("message-icon");
  const messageBubble = document.getElementById("message-bubble");
  messageBubble.classList.add("my-message");
  messageBubble.classList.remove("other-message");
  messageIcon.classList.add("icon-hidden");
  messageName.classList.remove("user-name-offset");
  message.classList.add("my-row", "message-own");
  message.classList.remove("other-row");
})