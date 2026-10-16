//2019.05.16

if (document.location.protocol == "file:") {
  alert(
    "ファイル直アクセスだと動きません。サーバーを起動してアクセスしてください"
  );
}



let gID;
let isError = false;

let CheckParam = {
  element: {},
  Init: function() {
    let prm = getParam();
    gID = prm["id"];
    if (gID == null) {
      isError = true;
    }
  }
};
var app = new Vue({
  el: "#vulinfoApp",
  data: {
    jsondata: "",
    item: {
      importance: "",
      version: "",
      jvn: [],
      severity: "",
      status: "",
      businessFields: [],
      list1Title: "",
      products: [],
      list2Title: "",
      thanks: "",
      history: [],
      url: "",
      authenticityGuarantee: "",
      // v2 fields
      docVersion: "",
      cveList: [],
      cve: [],
      impact: null,
      caution: null,
      interimMeasure: null,
      permanentMeasure: null,
      investigatingNote: null,
      contact: null
    },
    isError:false
  },
  methods: {
  },
  mounted: function() {
    var self = this;
    CheckParam.Init();

    if(isError){
      location.href = '/security/products/vulnerabilities/';
      return false;
    }
    if(gID !=undefined){
      let nowdate = new Date();
      let year = String(nowdate.getFullYear());
      let mon  = String(nowdate.getMonth() + 1);
      let date = String(nowdate.getDate());
      let random = String(Math.floor( Math.random() * 11 ));
      let dateParam = year+mon+date+random;

      let fileName;
      let isLocal = (document.location.hostname == "127.0.0.1"
          || document.location.hostname == "stg-prv-jrc.scms.jp.ricoh.com"
          || document.location.hostname == "stg-prv-wrc.scms.jp.ricoh.com");
      fileName = "https://vuls.ricoh.com/ja/vulinfo/" + gID.substr(6, 4) + "/" + gID + ".json?" + dateParam;
      function localizeVulUrl(url) {
        if (!isLocal) return url;
        return url
          .replace(/^https?:\/\/[^\/]+/, "")
          .replace(/\/vul(\?|$)/, "/vul.html$1")
          .replace(/\/adv(\?|$)/, "/adv.html$1")
          .replace(/\/product(\?|$)/, "/product.html$1")
          .replace(/\/list_products(\?|$)/, "/list_products.html$1");
      }
      //データロード
      var VULINFO_IDB_NAME = "vulinfoFolderHandleDB";
      var VULINFO_IDB_STORE = "handles";
      var VULINFO_IDB_KEY = "vulsRicohRoot";
      function openVulinfoHandleDB() {
        return new Promise(function (resolve, reject) {
          var req = indexedDB.open(VULINFO_IDB_NAME, 1);
          req.onupgradeneeded = function () {
            req.result.createObjectStore(VULINFO_IDB_STORE);
          };
          req.onsuccess = function () { resolve(req.result); };
          req.onerror = function () { reject(req.error); };
        });
      }
      function saveVulinfoRootHandle(handle) {
        return openVulinfoHandleDB().then(function (db) {
          return new Promise(function (resolve, reject) {
            var tx = db.transaction(VULINFO_IDB_STORE, "readwrite");
            tx.objectStore(VULINFO_IDB_STORE).put(handle, VULINFO_IDB_KEY);
            tx.oncomplete = function () { resolve(); };
            tx.onerror = function () { reject(tx.error); };
          });
        });
      }
      function loadSavedVulinfoRootHandle() {
        return openVulinfoHandleDB().then(function (db) {
          return new Promise(function (resolve, reject) {
            var tx = db.transaction(VULINFO_IDB_STORE, "readonly");
            var req = tx.objectStore(VULINFO_IDB_STORE).get(VULINFO_IDB_KEY);
            req.onsuccess = function () { resolve(req.result || null); };
            req.onerror = function () { reject(req.error); };
          });
        });
      }
      function waitForUserClickToSelectFolder(message) {
        return new Promise(function (resolve, reject) {
          var btn = document.createElement("button");
          btn.textContent = message;
          btn.style.position = "fixed";
          btn.style.top = "10px";
          btn.style.left = "10px";
          btn.style.zIndex = "9999";
          btn.style.padding = "10px 16px";
          btn.style.fontSize = "14px";
          btn.onclick = function () {
            btn.remove();
            resolve();
          };
          document.body.appendChild(btn);
        });
      }
      function pickAndSaveFolder() {
        return waitForUserClickToSelectFolder("ローカルのvuls.ricoh.comフォルダを選択")
          .then(function () {
            return window.showDirectoryPicker({ id: "vulsRicohRoot", mode: "read" });
          })
          .then(function (handle) {
            window.__vulsRicohRootHandle = handle;
            return saveVulinfoRootHandle(handle).then(function () { return handle; });
          });
      }
      function getVulsRicohRootHandle() {
        if (window.__vulsRicohRootHandle) {
          return Promise.resolve(window.__vulsRicohRootHandle);
        }
        if (!window.showDirectoryPicker) {
          return Promise.reject(new Error("File System Access API is not supported in this browser"));
        }
        return loadSavedVulinfoRootHandle()
          .catch(function () { return null; })
          .then(function (savedHandle) {
            if (!savedHandle) {
              return pickAndSaveFolder();
            }
            return savedHandle.queryPermission({ mode: "read" })
              .then(function (status) {
                if (status === "granted") {
                  window.__vulsRicohRootHandle = savedHandle;
                  return savedHandle;
                }
                return waitForUserClickToSelectFolder("vuls.ricoh.comフォルダへのアクセスを許可")
                  .then(function () {
                    return savedHandle.requestPermission({ mode: "read" });
                  })
                  .then(function (result) {
                    if (result === "granted") {
                      window.__vulsRicohRootHandle = savedHandle;
                      return savedHandle;
                    }
                    return pickAndSaveFolder();
                  });
              })
              .catch(function () {
                return pickAndSaveFolder();
              });
          });
      }
      function loadVulDataViaFolderHandle() {
        var yearDir = gID.substr(6, 4);
        var jsonName = gID + ".json";
        return getVulsRicohRootHandle()
          .then(function (rootHandle) {
            return rootHandle.getDirectoryHandle("ja");
          })
          .then(function (jaHandle) {
            return jaHandle.getDirectoryHandle("vulinfo");
          })
          .then(function (vulinfoHandle) {
            return vulinfoHandle.getDirectoryHandle(yearDir);
          })
          .then(function (yearHandle) {
            return yearHandle.getFileHandle(jsonName);
          })
          .then(function (fileHandle) {
            return fileHandle.getFile();
          })
          .then(function (file) {
            return file.text();
          })
          .then(function (text) {
            return { data: JSON.parse(text) };
          });
      }
      (isLocal ? loadVulDataViaFolderHandle() : axios.get(fileName))
      .then(function(response) {
        var d = response.data;

        // docVersion の正規化（なければ "1.0" 扱い）
        d["docVersion"] = d["docVersion"] || "1.0";
        var isV2 = (d["docVersion"] === "2.0");

        //表示用データ作成
        //最終更新日
        var tempLastUpdate = d["updatedAt"];
        var tempLastUpdateDT = new Date(Date.parse(tempLastUpdate));
        d["lastUpdate"] = dayjs(tempLastUpdateDT).format('YYYY年MM月DD日 H時mm分');
        //発行日
        var tempFirstEdition = d["publishedAt"];
        var tempFirstEditionDT = new Date(Date.parse(tempFirstEdition));
        d["firstEdition"] = dayjs(tempFirstEditionDT).format('YYYY年MM月DD日 H時mm分');

        // --- v2 固有処理 ---
        if (isV2) {
          // cveList をそのまま使う（テンプレート側で cveList を参照）
          d["cveList"] = d["cveList"] || [];
          // 旧テンプレート用 cve フィールドも互換のため生成
          d["cve"] = d["cveList"].map(function(c) {
            return { id: c.id, url: c.url || "", cwe: c.cwe || [] };
          });
          // productStatus から製品リストを取り出す
          d["businessFields"] = (d.productStatus && d.productStatus.businessFields) ? d.productStatus.businessFields : [];
          d["list1Title"]     = (d.productStatus && d.productStatus.list1Title) ? d.productStatus.list1Title : "";
          d["list2Title"]     = (d.productStatus && d.productStatus.list2Title) ? d.productStatus.list2Title : "";
          d["products"]       = (d.productStatus && d.productStatus.products) ? d.productStatus.products : [];

          // businessFields のカウント
          for (var i = 0; i < d["businessFields"].length; i++) {
            d["businessFields"][i]["count"] = 0;
            var categories = d["businessFields"][i]["categories"];
            for (var s = 0; s < categories.length; s++) {
              d["businessFields"][i]["categories"][s]["count"] = 0;
              var subcategories = categories[s]["subCategories"];
              for (var l = 0; l < subcategories.length; l++) {
                d["businessFields"][i]["count"]++;
                d["businessFields"][i]["categories"][s]["count"]++;
              }
            }
          }

          // v2 では contact は {text, links[]} オブジェクト
          // テンプレート側で item.contact.text / item.contact.links を参照

          // isLocal のとき versionCheck.url / countermeasure.links[].url をローカライズ
          if (isLocal) {
            for (var pi = 0; pi < d["products"].length; pi++) {
              var prod = d["products"][pi];
              if (prod.versionCheck && prod.versionCheck.url) {
                prod.versionCheck.url = localizeVulUrl(prod.versionCheck.url);
              }
              if (prod.countermeasure && prod.countermeasure.links) {
                for (var li = 0; li < prod.countermeasure.links.length; li++) {
                  prod.countermeasure.links[li].url = localizeVulUrl(prod.countermeasure.links[li].url);
                }
              }
            }
            // contact links のローカライズ
            if (d.contact && d.contact.links) {
              for (var ci = 0; ci < d.contact.links.length; ci++) {
                d.contact.links[ci].url = localizeVulUrl(d.contact.links[ci].url);
              }
            }
          }

        // --- v1 処理（従来通り） ---
        } else {
          d["businessFields"] = d.productStatus ? d.productStatus.businessFields : (d["businessFields"] || []);
          for (var i = 0; i < d["businessFields"].length; i++) {
            d["businessFields"][i]["count"] = 0;
            var categories = d["businessFields"][i]["categories"];
            for (var s = 0; s < categories.length; s++) {
              d["businessFields"][i]["categories"][s]["count"] = 0;
              var subcategories = categories[s]["subCategories"];
              for (var l = 0; l < subcategories.length; l++) {
                d["businessFields"][i]["count"]++;
                d["businessFields"][i]["categories"][s]["count"]++;
              }
            }
          }
          d["products"] = d.productStatus ? d.productStatus.products : (d["products"] || []);
          // v1: products[].id はHTMLリンク文字列 → ローカライズ
          if (isLocal) {
            for (var pi = 0; pi < d["products"].length; pi++) {
              var prod = d["products"][pi];
              if (typeof prod.id === "string") {
                prod.id = prod.id.replace(/href='([^']*)'/g,
                  function(m, url){ return "href='" + localizeVulUrl(url) + "'"; }
                );
                prod.id = prod.id.replace(/href="([^"]*)"/g,
                  function(m, url){ return 'href="' + localizeVulUrl(url) + '"'; }
                );
                prod.id = prod.id.replace(/>https?:\/\/[^<]*<\/a>/g,
                  function(m){
                    var text = m.slice(1, -4);
                    return '>' + document.location.origin + localizeVulUrl(text) + '</a>';
                  }
                );
              }
            }
          }
          // v1: cve フィールドをそのまま使う
          d["cve"] = d["cve"] || [];
          // v1: contact は HTML 文字列のまま
        }

        // history の date フィールド
        for (var hi = 0; hi < d.history.length; hi++) {
          d.history[hi]["date"] = d.history[hi]["updatedAt"];
        }

        // 本ページのURL のホスト名を動作中のホストに置き換え（ローカルは .html も補完）
        if (d.url) {
          d.url = d.url.replace(/^https?:\/\/[^\/]+/, window.location.origin);
          if (isLocal) {
            d.url = d.url.replace(/\/vul(\?|$)/, "/vul.html$1");
          }
        }

        // 全処理が終わってから Vue に渡す → reactivity が一度だけ発火
        self.item = d;
      })
      .catch(function (error) {
          self.isError = true;
          location.href = '/security/products/vulnerabilities/';
          return false;
      });
    }else{
      self.isError = true;
    }
  }
});

function getParam() {
  // URLのハッシュを取得
  var queryStr = location.search.substring(1);
  var prm = {};
  // URLにハッシュが存在する場合
  if (queryStr) {
    // 「&」が含まれている場合は「&」で分割
    var param = queryStr.split("&");
    // ハッシュを格納する用の配列を用意
    var pageNum;
    // 用意した配列にハッシュを格納
    for (i = 0; i < param.length; i++) {
      var paramItem = param[i].split("=");
      if (paramItem[0] == "id") {
        idNum = paramItem[1];
      }
    }
    //ハッシュの配列をオブジェクトに格納
    prm["id"] = idNum;
  } else {
    //ハッシュなし
    isError = true;
  }
  return prm;
}


