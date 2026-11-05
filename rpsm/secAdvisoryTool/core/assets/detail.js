// detail.js
// /item.json?id=... を取得して、1件分の脆弱性情報の詳細をレンダリングする
// 最小構成のVue 3アプリ。create/modify実行後のPDF化対象ページ。

const { createApp } = Vue;

function getIdFromQuery() {
  const params = new URLSearchParams(window.location.search);
  return params.get("id") || "";
}

const KNOWN_FIELDS = [
  "id",
  "title",
  "importance",
  "severity",
  "cve",
  "jvn",
  "publishedAt",
  "updatedAt",
];

createApp({
  data() {
    return {
      id: getIdFromQuery(),
      item: null,
      notFound: false,
      error: null,
      generatedAt: new Date().toLocaleString("ja-JP"),
    };
  },
  computed: {
    severityClass() {
      if (!this.item || !this.item.severity) return "";
      return "severity severity-" + String(this.item.severity).toLowerCase();
    },
    // 固定フィールド以外＝子テーブル由来の追加フィールド（例: affectedProducts）
    childSections() {
      if (!this.item) return [];
      return Object.keys(this.item)
        .filter((key) => !KNOWN_FIELDS.includes(key))
        .map((key) => {
          const rows = Array.isArray(this.item[key]) ? this.item[key] : [];
          const columns = rows.length > 0 ? Object.keys(rows[0]) : [];
          return { key, rows, columns };
        });
    },
  },
  mounted() {
    const self = this;
    if (!self.id) {
      self.error = "URLに ?id=... が指定されていません。";
      document.body.setAttribute("data-render-complete", "true");
      return;
    }
    fetch("/item.json?id=" + encodeURIComponent(self.id))
      .then(function (res) {
        if (res.status === 404) {
          self.notFound = true;
          return null;
        }
        if (!res.ok) {
          throw new Error("HTTP " + res.status);
        }
        return res.json();
      })
      .then(function (data) {
        if (data) {
          self.item = data;
        }
        document.body.setAttribute("data-render-complete", "true");
      })
      .catch(function (err) {
        self.error = String(err);
        document.body.setAttribute("data-render-complete", "true");
      });
  },
}).mount("#app");
