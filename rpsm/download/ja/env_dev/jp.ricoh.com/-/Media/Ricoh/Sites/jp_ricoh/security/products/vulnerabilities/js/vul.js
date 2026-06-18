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
    item: "",
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
        self.item = response.data;
        //表示用データ作成
        //最終更新日
        tempLastUpdate = self.item["updatedAt"];
        let tempLastUpdateTS = Date.parse(tempLastUpdate);
        let tempLastUpdateDT = new Date(tempLastUpdateTS);
        self.item["lastUpdate"] = dayjs(tempLastUpdateDT).format('YYYY年MM月DD日 H時mm分');
        //発行日
        tempFirstEdition = self.item["publishedAt"];
        let tempFirstEditionTS = Date.parse(tempFirstEdition);
        let tempFirstEditionDT = new Date(tempFirstEditionTS);
        self.item["firstEdition"] = dayjs(tempFirstEditionDT).format('YYYY年MM月DD日 H時mm分');
        //
        self.item["businessFields"] = self.item.productStatus.businessFields;
        for(let i=0; i<self.item["businessFields"].length; i++){
          self.item["businessFields"][i]["count"]=0;
          let categories = self.item["businessFields"][i]["categories"];
          for(let s=0; s<categories.length; s++){
            self.item["businessFields"][i]["categories"][s]["count"]=0;
            let subcategories = categories[s]["subCategories"];
            for(let l=0; l<subcategories.length; l++){
              self.item["businessFields"][i]["count"]++;
              self.item["businessFields"][i]["categories"][s]["count"]++;
            }
          }
        }
        self.item["products"] = self.item.productStatus.products;
        for(i=0; i<self.item.history.length; i++){
          self.item.history[i]["date"] = self.item.history[i]["updatedAt"];//最終更新日
        }
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


