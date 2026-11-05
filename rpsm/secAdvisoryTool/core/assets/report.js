// report.js
// /vulinfolist.json を取得して描画する、最小構成のVue 3アプリ。
// 将来的にリコー本番ページの vulinfo_search.js（Vue2 + jQuery + axios版、検索絞り込みやページングを含む）
// を流用したくなった場合も、データ取得元（/vulinfolist.json）とDOM構造（vulinfoApp相当）の
// 考え方はこのサンプルと揃えてあるので置き換えやすいはず。

const { createApp } = Vue;

createApp({
  data() {
    return {
      items: [],
      error: null,
      generatedAt: new Date().toLocaleString("ja-JP"),
    };
  },
  mounted() {
    const self = this;
    fetch("/vulinfolist.json")
      .then(function (res) {
        if (!res.ok) {
          throw new Error("HTTP " + res.status);
        }
        return res.json();
      })
      .then(function (data) {
        self.items = data;
        // ヘッドレスブラウザでPDF化する際に「描画完了」を検知しやすいよう、
        // 目印の属性をbodyに立てておく（--virtual-time-budget と併用）。
        document.body.setAttribute("data-render-complete", "true");
      })
      .catch(function (err) {
        self.error = String(err);
        document.body.setAttribute("data-render-complete", "true");
      });
  },
}).mount("#app");
