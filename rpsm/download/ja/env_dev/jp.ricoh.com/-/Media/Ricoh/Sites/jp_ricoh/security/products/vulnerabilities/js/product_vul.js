//2019.05.16

if (document.location.protocol == "file:") {
  alert(
    "ファイル直アクセスだと動きません。サーバーを起動してアクセスしてください"
  );
}



let gID;
let isError = false;
let gCurrentPage;



var app = new Vue({
  el: "#vulinfoApp",
  data: {
    jsondata: "",
    allItems: [], //論理削除対象以外の全データ

    optionsInitialDay: [],
    optionsLastUpDay: [],

    filterByImportance:"",
    filterBySeverity:"",
    filterByKeyword:"",
    filterByCVE:"",
    filterByJVN:"",
    filterByInitialDate:"",
    filterByLastUpDate:"",
    jsonid:"",

    items: [], //表示用データ
    item: [], //表示用データ
    ids: [],
    totalNum: 0,
    totalPage: 0,
    numForPage: 20,
    startNum: 0,
    endNum: 0,
    pageStart: 0,
    pageEnd: 0,
    pageCurrent: 1,
    pagenate: [],
    hashNotIncludePage: "",
    isModel:false,
    loadingText:"読み込み中",

    flgPrev: true,
    flgNext: true,
    flgPrevDot: true,
    flgNextDot: true,
    urlPrev: "",
    urlNext: "",
    urlFirst: "",
    urlLast: "",
    serchCondition: [],
    searchWords: "",
    searchWordsLink: {}
  },
  methods: {
    gotoSearch: function() {
      var self = this;
      self.makeHashStr();
      window.location.href = "?p=1"+self.hashNotIncludePage;
    },
    checkHash:function(){
      const self = this;
      let prm = getParam();
      if (prm["p"] == null) {
        prm["p"] = 1;
      }
      self.pageCurrent = prm["p"];
      self.jsonid = prm["id"];
      self.filterByImportance = prm["importance"];
      self.filterBySeverity = prm["severity"];
      self.filterByKeyword = prm["keyword"];
      self.filterByCVE = prm["cve"];
      self.filterByJVN = prm["jvn"];
      self.filterByInitialDate = prm["publish"];
      self.filterByLastUpDate = prm["update"];
    },
    makeItemAr: function() {//ページに必要な10件の抽出
      let self = this;
      //配列をリセット
      self.items = [];
      //検索結果
      self.totalNum = self.searchResult.length;
      //現在のページに必要なもの10件を抽出
      self.startNum = self.numForPage * (self.pageCurrent - 1);
      self.endNum = self.numForPage * self.pageCurrent;
      //表示用の配列の生成
      for (var s = 0; s < self.totalNum; s++) {
        if (s >= self.startNum && s < self.endNum) {
          self.items.push(self.searchResult[s]);
        }
      }
    },
    makeHashStr: function(_currentPage) {
      const self = this;
      let hash = "p=" + _currentPage;
      self.hashNotIncludePage = "";

      if(self.jsonid!=""){
        self.hashNotIncludePage += "&id=" + self.jsonid;
      }
      if(self.filterByImportance!=""){
        self.hashNotIncludePage += "&importance=" + self.filterByImportance;
      }
      if(self.filterBySeverity!=""){
        self.hashNotIncludePage += "&severity=" + self.filterBySeverity;
      }
      if(self.filterByKeyword!=""){
        self.hashNotIncludePage += "&keyword=" + self.filterByKeyword;
      }
      if(self.filterByCVE!=""){
        self.hashNotIncludePage += "&cve=" + self.filterByCVE;
      }
      if(self.filterByJVN!=""){
        self.hashNotIncludePage += "&jvn=" + self.filterByJVN;
      }
      if(self.filterByInitialDate!=""){
        self.hashNotIncludePage += "&publish=" + self.filterByInitialDate;
      }
      if(self.filterByLastUpDate!=""){
        self.hashNotIncludePage += "&update=" + self.filterByLastUpDate;
      }
    },
    sortItems: function() {//絞り込み検索処理
      const self = this;
      //IMPORTANCE
      let tempArray_importance =[];
      if(self.filterByImportance!=""){
        for (let i = 0; i < self.allItems.length; i++) {
          let tempItem = self.allItems[i];
          if(self.filterByImportance=="Important"){
            if(tempItem.importance=="Important"){
              tempArray_importance.push(self.allItems[i]);
            }
          }else{
              tempArray_importance.push(self.allItems[i]);
          }
        }
      }else{
        tempArray_importance = self.allItems;
      }
      //SEVERITY
      let tempArray_severity =[];
      if(self.filterBySeverity!=""){
        for (let i = 0; i < tempArray_importance.length; i++) {
          let tempItem = tempArray_importance[i];
          if(tempItem["severity"].includes(self.filterBySeverity)){
            tempArray_severity.push(tempItem);
          }
        }
      }else{
        tempArray_severity = tempArray_importance;
      }

      //KEYWORDS
      let tempArray_keyword =[];
      let filterByKeywordUpperCase = self.filterByKeyword.toUpperCase();//すべて大文字に変換
      let keywordsArray = filterByKeywordUpperCase.split(/\s/);
      
      if(self.filterByKeyword!=""){
        for (let i = 0; i < tempArray_severity.length; i++) {
          let tempItem = tempArray_severity[i];
          let tempItemTitleUpperCase = tempItem["title"].toUpperCase();
          let isKeyword = keywordsArray.some((value, index, array) => {
            return tempItemTitleUpperCase.includes(value);
          });
          if(isKeyword){
            tempArray_keyword.push(tempItem);
          }
        }
      }else{
        tempArray_keyword = tempArray_severity;
      }

      //CVE
      let tempArray_cve =[];
      if(self.filterByCVE!=""){
        for (let i = 0; i < tempArray_keyword.length; i++) {
          let tempItem = tempArray_keyword[i];
          for (let s = 0; s < tempItem["cve"].length; s++) {
            if(tempItem["cve"][s]["id"].includes(self.filterByCVE)){
              tempArray_cve.push(tempItem);
              break;
            }
          }
        }
      }else{
        tempArray_cve = tempArray_keyword;
      }

      //JVN
      let tempArray_jvn =[];
      if(self.filterByJVN!=""){
        for (let i = 0; i < tempArray_cve.length; i++) {
          let tempItem = tempArray_cve[i];
          for (let s = 0; s < tempItem["jvn"].length; s++) {
            if(tempItem["jvn"][s]["id"].includes(self.filterByJVN)){
              tempArray_jvn.push(tempItem);
              break;
            }
          }
        }
      }else{
        tempArray_jvn = tempArray_cve;
      }

      //PUBLISH
      let tempArray_publish =[];
      if(self.filterByInitialDate!=""){
        for (let i = 0; i < tempArray_jvn.length; i++) {
          let tempItem = tempArray_jvn[i];
          let tempUnixConditionBefore = new Date(Date.parse(self.filterByInitialDate+"-01"));
          tempUnixConditionBefore = tempUnixConditionBefore.getTime();

          let tempUnixConditionAfter = new Date(Date.parse(self.filterByInitialDate+"-01"));
          tempUnixConditionAfter.setMonth(tempUnixConditionAfter.getMonth() + 1);
          tempUnixConditionAfter = tempUnixConditionAfter.getTime();


          const tempMMYYDD = tempItem["publishedAt"].substr( 0, 10 );
          let tempMMYYDDArray = tempMMYYDD.split("-");
          tempMMYYDDArray[1] = Number(tempMMYYDDArray[1]) - 1;
          let tempUnix = new Date(Date.UTC(Number(tempMMYYDDArray[0]), Number(tempMMYYDDArray[1]), Number(tempMMYYDDArray[2])));
          tempUnix = tempUnix.getTime();
          if(tempUnix > tempUnixConditionBefore && tempUnix < tempUnixConditionAfter){
            tempArray_publish.push(tempItem);
          }
        }
      }else{
        tempArray_publish = tempArray_jvn;
      }

      //UPDATE
      let tempArray_update =[];
      if(self.filterByLastUpDate!=""){
        for (let i = 0; i < tempArray_publish.length; i++) {
          let tempItem = tempArray_publish[i];
          let tempUnixConditionBefore = new Date(Date.parse(self.filterByLastUpDate+"-01"));
          tempUnixConditionBefore = tempUnixConditionBefore.getTime();

          let tempUnixConditionAfter = new Date(Date.parse(self.filterByLastUpDate+"-01"));
          tempUnixConditionAfter.setMonth(tempUnixConditionAfter.getMonth() + 1);
          tempUnixConditionAfter = tempUnixConditionAfter.getTime();

          const tempMMYYDD = tempItem["updatedAt"].substr( 0, 10 );
          let tempMMYYDDArray = tempMMYYDD.split("-");
          tempMMYYDDArray[1] = Number(tempMMYYDDArray[1]) - 1;
          let tempUnix = new Date(Date.UTC(Number(tempMMYYDDArray[0]), Number(tempMMYYDDArray[1]), Number(tempMMYYDDArray[2])));
          tempUnix = tempUnix.getTime();
          if(tempUnix > tempUnixConditionBefore && tempUnix < tempUnixConditionAfter){
            tempArray_update.push(tempItem);
          }
        }
      }else{
        tempArray_update = tempArray_publish;
      }

      self.searchResult = tempArray_update;
    },
    getPageStartEnd: function() {
      var self = this;
      self.totalPage = Math.ceil(self.totalNum / self.numForPage);
      self.pageCurrent = Number(self.pageCurrent);//強制的に数字に変換
      if (self.totalPage < 6) {
        self.pageStart = 1;
        self.pageEnd = self.totalPage;
      } else {
        self.pageStart = self.pageCurrent - 2;
        self.pageEnd = self.pageCurrent + 2;
        if (self.pageStart < 1) {
          self.pageStart = 1;
          self.pageEnd = 5;
        }
        if (self.pageEnd > self.totalPage) {
          self.pageEnd = self.totalPage;
          self.pageStart = self.totalPage - 4;
        }
      }
      //ページング省略処理
      if (self.pageStart == 1) {
        self.flgPrevDot = false;
      } else {
        self.flgPrevDot = true;
      }
      if (self.pageEnd == self.totalPage) {
        self.flgNextDot = false;
      } else {
        self.flgNextDot = true;
      }
    },
    makePaging: function() {
      var self = this;
      var tempPagenation = 0;
      self.pagenate = [];
      for (var i = self.pageStart; i <= self.pageEnd; i++) {
        var tempObj = {};
        tempObj["page"] = i;
        tempObj["url"] = "/security/products/vulnerabilities/product.html?p=" + i + self.hashNotIncludePage;
        if (i == self.pageCurrent) {
          tempObj["active"] = "act";
        } else {
          tempObj["active"] = "";
        }
        self.pagenate.push(tempObj);
        tempPagenation++;
      }

      //BACKボタン
      if (self.pageCurrent != 1) {
        self.urlPrev =
          //"/security/products/vulnerabilities/product?p=" +
          "/security/products/vulnerabilities/product.html?p=" +
          (self.pageCurrent - 1) +
          self.hashNotIncludePage;
        self.flgPrev = true;
      } else {
        self.flgPrev = false;
      }

      //NEXTボタン
      if (self.pageCurrent != self.totalPage) {
        //self.urlNext = "/security/products/vulnerabilities/product?p=" + (self.pageCurrent + 1) + self.hashNotIncludePage;
        self.urlNext = "/security/products/vulnerabilities/product.html?p=" + (self.pageCurrent + 1) + self.hashNotIncludePage;
        self.flgNext = true;
      } else {
        self.flgNext = false;
      }
      //最初と最後のボタン
      //self.urlFirst = "/security/products/vulnerabilities/product?p=1" + self.hashNotIncludePage;
      //self.urlLast = "/security/products/vulnerabilities/product?p=" + self.totalPage + self.hashNotIncludePage;
      self.urlFirst = "/security/products/vulnerabilities/product.html?p=1" + self.hashNotIncludePage;
      self.urlLast = "/security/products/vulnerabilities/product.html?p=" + self.totalPage + self.hashNotIncludePage;
    },
    hideCover: function() {
      $("#vulWrap_cover").animate({ opacity: 0 }, 400, function() {
        $("#vulWrap_cover").css("display", "none");
      });
    }
  },
  mounted: function() {
    var self = this;
    self.checkHash();

    // ← 追加：アコーディオン内の操作で外側のトグルに届かないようにする
    const panel = document.getElementById('searchAccordionControls');
    if (panel) {
      ['click','change','input','keydown','mousedown','touchstart','focusin'].forEach(evt => {
        panel.addEventListener(evt, (e) => {
          // フォーム操作・リンククリックなどだけ拾って止める
          if (e.target.closest('input, select, textarea, button, a')) {
            e.stopPropagation();
          }
        }, true); // captureで先に受けるのがポイント
      });
    }

    //読み込むJSONファイル名
    let nowdate = new Date();
    let year = String(nowdate.getFullYear());
    let mon  = String(nowdate.getMonth() + 1);
    let date = String(nowdate.getDate());
    let random = String(Math.floor( Math.random() * 11 ));
    let dateParam = year+mon+date+random;

    let fileName = "https://vuls.ricoh.com/ja/prodinfo/"+self.jsonid+".json?"+dateParam;
    //let fileName = "/-/Media/Ricoh/Sites/jp_ricoh/security/products/vulnerabilities/data/prodinfo/"+self.jsonid+".json?"+dateParam;
    let offsetVar = $("#vulinfoApp").offset();
    let scrollPost = offsetVar.top;

    //Hash監視
    window.onhashchange = function() {
      $("html,body").animate(
        {
          scrollTop: scrollPost
        },
        1000,
        "easeOutQuint"
      );
      $("#vulWrap_cover").css("display", "block");
      $("#vulWrap_cover").css("opacity", 100);
      setTimeout(function() {
        self.checkHash();
        self.makeHashStr(self.pageCurrent);
        self.sortItems();
        self.makeItemAr();
        self.getPageStartEnd();
        self.makePaging();
        self.hideCover();
      }, 600);
    };

    let isLocal = (document.location.hostname == "127.0.0.1"
        || document.location.hostname == "stg-prv-wrc.scms.jp.ricoh.com"
        || document.location.hostname == "stg-prv-jrc.scms.jp.ricoh.com");
    function localizeProductUrl(url) {
      if (!isLocal) return url;
      return url
        .replace(/\/vul(\?|$)/, "/vul.html$1")
        .replace(/\/adv(\?|$)/, "/adv.html$1")
        .replace(/\/product(\?|$)/, "/product.html$1")
        .replace(/\/list_products(\?|$)/, "/list_products.html$1");
    }
    //データロード
    var PRODUCT_IDB_NAME = "vulinfoFolderHandleDB";
    var PRODUCT_IDB_STORE = "handles";
    var PRODUCT_IDB_KEY = "vulsRicohRoot";
    function openProductHandleDB() {
      return new Promise(function (resolve, reject) {
        var req = indexedDB.open(PRODUCT_IDB_NAME, 1);
        req.onupgradeneeded = function () {
          req.result.createObjectStore(PRODUCT_IDB_STORE);
        };
        req.onsuccess = function () { resolve(req.result); };
        req.onerror = function () { reject(req.error); };
      });
    }
    function saveProductRootHandle(handle) {
      return openProductHandleDB().then(function (db) {
        return new Promise(function (resolve, reject) {
          var tx = db.transaction(PRODUCT_IDB_STORE, "readwrite");
          tx.objectStore(PRODUCT_IDB_STORE).put(handle, PRODUCT_IDB_KEY);
          tx.oncomplete = function () { resolve(); };
          tx.onerror = function () { reject(tx.error); };
        });
      });
    }
    function loadSavedProductRootHandle() {
      return openProductHandleDB().then(function (db) {
        return new Promise(function (resolve, reject) {
          var tx = db.transaction(PRODUCT_IDB_STORE, "readonly");
          var req = tx.objectStore(PRODUCT_IDB_STORE).get(PRODUCT_IDB_KEY);
          req.onsuccess = function () { resolve(req.result || null); };
          req.onerror = function () { reject(req.error); };
        });
      });
    }
    function waitForUserClickToSelectFolderProduct(message) {
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
    function pickAndSaveFolderProduct() {
      return waitForUserClickToSelectFolderProduct("ローカルのvuls.ricoh.comフォルダを選択")
        .then(function () {
          return window.showDirectoryPicker({ id: "vulsRicohRoot", mode: "read" });
        })
        .then(function (handle) {
          window.__vulsRicohRootHandle = handle;
          return saveProductRootHandle(handle).then(function () { return handle; });
        });
    }
    function getVulsRicohRootHandleProduct() {
      if (window.__vulsRicohRootHandle) {
        return Promise.resolve(window.__vulsRicohRootHandle);
      }
      if (!window.showDirectoryPicker) {
        return Promise.reject(new Error("File System Access API is not supported in this browser"));
      }
      return loadSavedProductRootHandle()
        .catch(function () { return null; })
        .then(function (savedHandle) {
          if (!savedHandle) {
            return pickAndSaveFolderProduct();
          }
          return savedHandle.queryPermission({ mode: "read" })
            .then(function (status) {
              if (status === "granted") {
                window.__vulsRicohRootHandle = savedHandle;
                return savedHandle;
              }
              return waitForUserClickToSelectFolderProduct("vuls.ricoh.comフォルダへのアクセスを許可")
                .then(function () {
                  return savedHandle.requestPermission({ mode: "read" });
                })
                .then(function (result) {
                  if (result === "granted") {
                    window.__vulsRicohRootHandle = savedHandle;
                    return savedHandle;
                  }
                  return pickAndSaveFolderProduct();
                });
            })
            .catch(function () {
              return pickAndSaveFolderProduct();
            });
        });
    }
    function loadProductDataViaFolderHandle() {
      return getVulsRicohRootHandleProduct()
        .then(function (rootHandle) {
          return rootHandle.getDirectoryHandle("ja");
        })
        .then(function (jaHandle) {
          return jaHandle.getDirectoryHandle("prodinfo");
        })
        .then(function (prodinfoHandle) {
          return prodinfoHandle.getFileHandle(self.jsonid + ".json");
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
    (isLocal ? loadProductDataViaFolderHandle() : axios.get(fileName))
      .then(function(response) {
        self.item = response.data;
        console.log(fileName);
        //表示用データ作成
        self.allItems = self.item.advisories;
        

        for(i=0; i<self.allItems.length; i++){
          //リンク先
          self.allItems[i]["linkUrl"] = localizeProductUrl(
            "/security/products/vulnerabilities/adv?id=" + self.allItems[i].id
          );
          //最終更新日
          tempLastUpdate = self.allItems[i]["updatedAt"];
          let days = tempLastUpdate.split('+');
          let tempLastDate = tempLastUpdate.substr( 0, 10 );
          let tempLastTime = "+" + days[1];
          
          self.allItems[i]["lastUpdate"] = tempLastDate + tempLastTime;

          //発行日
          tempFirstEdition = self.allItems[i]["publishedAt"];
          let days2 = tempFirstEdition.split('+');
          let tempFirstDate = tempFirstEdition.substr( 0, 10 );
          let tempFirstTime = "+" + days[1];
          self.allItems[i]["firstEdition"] = tempFirstDate + tempFirstTime;
        }

        //オプションの配列の順序をソート
        let tempLastUpDateAr =[];
        let tempFirstDateAr =[];

        for(i=0; i<self.allItems.length; i++){
          //最終発行日
          tempLastUpdate = self.allItems[i]["updatedAt"];
          let tempLastUpMonth = tempLastUpdate.substr( 0, 7 );
          if (tempLastUpDateAr.indexOf(tempLastUpMonth) == -1) {
            tempLastUpDateAr.push(tempLastUpMonth);
          }
          //発行日
          tempFirstEdition = self.allItems[i]["publishedAt"];
          let tempFirstMonth = tempFirstEdition.substr( 0, 7 );
          if (tempFirstDateAr.indexOf(tempFirstMonth) == -1) {
            tempFirstDateAr.push(tempFirstMonth);
          }
        }
        tempLastUpDateAr.sort();
        tempLastUpDateAr.reverse();
        tempFirstDateAr.sort();
        tempFirstDateAr.reverse();
        for(i=0; i<tempLastUpDateAr.length; i++){
          let tempLastUpdateMonthObj = {} 
          tempLastUpdateMonthObj["text"] = tempLastUpDateAr[i];
          tempLastUpdateMonthObj["value"] = tempLastUpDateAr[i];
          self.optionsLastUpDay.push(tempLastUpdateMonthObj);
        }
        for(i=0; i<tempFirstDateAr.length; i++){
          let tempFirstMonthObj = {} 
          tempFirstMonthObj["text"] = tempFirstDateAr[i];
          tempFirstMonthObj["value"] = tempFirstDateAr[i];
          self.optionsInitialDay.push(tempFirstMonthObj);
        }

        //絞り込み検索
        self.sortItems();

        //modelが存在するかどうかチェック
        for(let i=0; i<self.searchResult.length; i++){
          if(self.searchResult[i].model !=""){
            self.isModel = true;
          }
        }

        //0件かどうか？
        if(self.totalNum == 0){
          self.loadingText = "一致するデータが見つかりません。";
        }else{
          self.loadingText = "読込中";
        }

        //現在に必要な10件の配列itemsを作成
        self.makeItemAr();

        //ページング処理
        self.makeHashStr(self.pageCurrent);
        self.getPageStartEnd();
        self.makePaging();
      })
      .catch(function (error) {
        self.isError = true;
        location.href = '/security/products/vulnerabilities/';
        return false;
    });
  }
});

function toISOStringWithTimezone(date) {
  const pad = function (str) {
      return ('0' + str).slice(-2);
  };
  const year = (date.getFullYear()).toString();
  const month = pad((date.getMonth() + 1).toString());
  const day = pad(date.getDate().toString());
  const hour = pad(date.getHours().toString());
  const min = pad(date.getMinutes().toString());
  const sec = pad(date.getSeconds().toString());
  const tz = -date.getTimezoneOffset();
  const sign = tz >= 0 ? '+' : '-';
  const tzHour = pad((tz / 60).toString());
  const tzMin = pad((tz % 60).toString());

  return `${year}-${month}-${day}T${hour}:${min}:${sec}${sign}${tzHour}:${tzMin}`;
}
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
    var id;
    var filterImportance = "";
    var filterSeveritye = "";
    var filterKeyword = "";
    var filterCve = "";
    var filterJvn = "";
    var filterFday = "";
    var filterLday = "";
    // 用意した配列にハッシュを格納
    for (i = 0; i < param.length; i++) {
      var paramItem = param[i].split("=");
      if (paramItem[0] == "p") {
        pageNum = paramItem[1];
      } else if (paramItem[0] == "id") {
        id = paramItem[1];
      } else if (paramItem[0] == "importance") {
        filterImportance = paramItem[1];
      } else if (paramItem[0] == "severity") {
        filterSeveritye = paramItem[1];
      } else if (paramItem[0] == "keyword") {
        paramItem[1] = decodeURI(paramItem[1]);
        filterKeyword = paramItem[1];
      }else if (paramItem[0] == "cve") {
        filterCve = paramItem[1];
      }else if (paramItem[0] == "jvn") {
        filterJvn = paramItem[1];
      }else if (paramItem[0] == "publish") {
        filterFday = paramItem[1];
      }else if (paramItem[0] == "update") {
        filterLday = paramItem[1];
      }
    }
    //ハッシュの配列をオブジェクトに格納
    prm["p"] = pageNum;
    prm["id"] = id;
    prm["importance"] = filterImportance;
    prm["severity"] = filterSeveritye;
    prm["keyword"] = filterKeyword;
    prm["cve"] = filterCve;
    prm["jvn"] = filterJvn;
    prm["publish"] = filterFday;
    prm["update"] = filterLday;
  } else {
    //ハッシュなし
    isError = true;
    if(isError){
      location.href = '/security/products/vulnerabilities/';
      return false;
    }
  }
  return prm;
}


