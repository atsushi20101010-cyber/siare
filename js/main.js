/* ============================================ */
/* ハンバーガーメニュー開閉                       */
/* ============================================ */
(function () {
  'use strict';

  var toggle = document.getElementById('nav-toggle');
  var nav = document.getElementById('global-nav');

  if (!toggle || !nav) {
    return;
  }

  function closeMenu() {
    nav.classList.remove('is-open');
    toggle.classList.remove('is-active');
    toggle.setAttribute('aria-expanded', 'false');
    toggle.setAttribute('aria-label', 'メニューを開く');
  }

  function openMenu() {
    nav.classList.add('is-open');
    toggle.classList.add('is-active');
    toggle.setAttribute('aria-expanded', 'true');
    toggle.setAttribute('aria-label', 'メニューを閉じる');
  }

  toggle.addEventListener('click', function () {
    if (nav.classList.contains('is-open')) {
      closeMenu();
    } else {
      openMenu();
    }
  });

  // ナビ内リンクをタップしたらメニューを閉じる
  nav.addEventListener('click', function (e) {
    if (e.target.closest('a')) {
      closeMenu();
    }
  });

  // デスクトップ幅に戻ったら状態をリセット
  window.addEventListener('resize', function () {
    if (window.innerWidth >= 768) {
      closeMenu();
    }
  });
})();

/* ============================================ */
/* ヘッダー：スクロールで透過→白背景に切替        */
/* ============================================ */
(function () {
  'use strict';

  var header = document.getElementById('site-header');
  if (!header) {
    return;
  }

  var threshold = 60;
  var ticking = false;

  function update() {
    if (window.scrollY > threshold) {
      header.classList.add('is-scrolled');
    } else {
      header.classList.remove('is-scrolled');
    }
    ticking = false;
  }

  function onScroll() {
    if (!ticking) {
      window.requestAnimationFrame(update);
      ticking = true;
    }
  }

  window.addEventListener('scroll', onScroll, { passive: true });
  update();
})();

/* ============================================ */
/* お問い合わせフォーム送信（Web3Forms・非同期）  */
/* ============================================ */
(function () {
  'use strict';

  var form = document.getElementById('contact-form');
  if (!form) {
    return;
  }

  var status = document.getElementById('form-status');
  var button = form.querySelector('button[type="submit"]');

  function setStatus(message, state) {
    if (!status) {
      return;
    }
    status.textContent = message;
    status.className = 'form-status' + (state ? ' form-status--' + state : '');
  }

  form.addEventListener('submit', function (e) {
    e.preventDefault();

    setStatus('送信中です…', 'pending');
    if (button) {
      button.disabled = true;
    }

    // 日本語の項目名が文字化けしないよう JSON(UTF-8) で送信する
    var payload = {};
    new FormData(form).forEach(function (value, key) {
      payload[key] = value;
    });

    fetch(form.action, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Accept: 'application/json'
      },
      body: JSON.stringify(payload)
    })
      .then(function (res) {
        return res.json().then(function (data) {
          return { ok: res.ok, data: data };
        });
      })
      .then(function (result) {
        var success =
          result.ok &&
          (result.data.success === true || result.data.success === 'true');
        if (success) {
          form.reset();
          setStatus('送信が完了しました。担当者より折り返しご連絡いたします。', 'ok');
        } else {
          setStatus('送信に失敗しました。お手数ですが info@siare.co.jp までご連絡ください。', 'err');
        }
      })
      .catch(function () {
        setStatus('送信に失敗しました。通信環境をご確認のうえ、再度お試しください。', 'err');
      })
      .finally(function () {
        if (button) {
          button.disabled = false;
        }
      });
  });
})();
