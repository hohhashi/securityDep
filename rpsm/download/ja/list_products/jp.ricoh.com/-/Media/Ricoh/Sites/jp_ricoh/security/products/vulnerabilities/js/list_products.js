//2019.05.16

if (document.location.protocol == "file:") {
  alert(
    "ファイル直アクセスだと動きません。サーバーを起動してアクセスしてください"
  );
}

document.addEventListener('DOMContentLoaded', function () {
  // ── ラジオ群とパネルの切替 ───────────────────────────
  const radios = Array.from(document.querySelectorAll('input[name="sort"][aria-controls]'));

  const getPanel = (radio) => {
    const id = radio?.getAttribute('aria-controls');
    return id ? document.getElementById(id) : null;
  };

  function updatePanels(focusTarget /* ← 変更: フォーカス先を受け取る */) {
    radios.forEach(radio => {
      const panel = getPanel(radio);
      const active = !!radio.checked;
      if (!panel) return;

      panel.hidden = !active;                  // 非表示切替
      panel.toggleAttribute('inert', !active); // フォーカス抑止
      panel.setAttribute('aria-hidden', String(!active));
    });

    // ★ 選択したラジオにだけフォーカスを残す
    if (focusTarget instanceof HTMLElement) {
      focusTarget.focus();
    }
  }

  // 初期状態を反映（フォーカス移動なし）
  updatePanels();

  // ラジオ変更でパネル更新（選択したラジオをフォーカス先に渡す）
  radios.forEach(radio => {
    radio.addEventListener('change', (e) => {
      updatePanels(e.currentTarget);
    });
  });

  // ── URLハッシュ制御 ─────────────────────────────────
  function setHashOnly(hashValue) {
    const url = new URL(window.location.href);
    url.hash = hashValue;                 // 例: 'filterby=category'
    history.replaceState(null, '', url);  // 履歴を汚さず置換
    window.dispatchEvent(new HashChangeEvent("hashchange"));
  }

  const radioByType = document.getElementById('sortByType');
  const radioByName = document.getElementById('sortByName');

  if (radioByType) {
    radioByType.addEventListener('change', () => {
      if (radioByType.checked) setHashOnly('filterby=category');
    });
    if (radioByType.checked) setHashOnly('filterby=category');
  }

  if (radioByName) {
    radioByName.addEventListener('change', () => {
      if (radioByName.checked) setHashOnly('filterby=keyword');
    });
    if (radioByName.checked) setHashOnly('filterby=keyword');
  }
});

// 依存セレクト制御ヘルパー：Area未選択ならCategoryを、Category未選択ならSubCategoryをdisabledにする
function updateSelectInterlocks(vm) {
  const selArea = document.getElementById('filterByArea');
  const selCat  = document.getElementById('filterByCategory');
  const selSub  = document.getElementById('filterBySubCategory');

  const hasArea     = !!vm.filterByArea;
  const hasCategory = !!vm.filterByCategory;

  if (selCat) {
    selCat.disabled = !hasArea;
    selCat.setAttribute('aria-disabled', String(!hasArea));
  }
  if (selSub) {
    selSub.disabled = !hasCategory;
    selSub.setAttribute('aria-disabled', String(!hasCategory));
  }
}

// ハッシュから復元した filterBy* をセレクトへ反映（子のリセットはしない）
function applyHashToSelects(vm) {
  vm.optionsCategories    = vm.categories[vm.filterByArea] || [];
  vm.optionsSubCategories = vm.subcategories[vm.filterByCategory] || [];

  const selArea = document.getElementById('filterByArea');
  if (selArea) selArea.value = vm.filterByArea;

  const selCat = document.getElementById('filterByCategory');
  if (selCat) selCat.value = vm.filterByCategory;

  const selSub = document.getElementById('filterBySubCategory');
  if (selSub) selSub.value = vm.filterBySubCategory;

  updateSelectInterlocks(vm);
}



var app = new Vue({
  el: "#vulinfoApp",
  data: {
    selectedArea: '',
    selectedCategory: '',
    selectedSubCategory: '',
    categories: [],
    subcategories: [],

    optionsAreas: [],
    optionsCategories: [],
    optionsSubCategories: [],

    filterByArea:"",
    filterByCategory:"",
    filterBySubCategory:"",
    filterByKeyword:"",
    
    jsondata: "",
    allItems: [], //論理削除対象以外の全データ
    allItemsForCategory: [], //論理削除対象以外の全データ
    items: [], //表示用データ
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
    selectionArea: function () {
      var self = this;
      self.optionsCategories = self.categories[self.filterByArea] || [];

      // 親(Area)が変わったら子をリセット
      self.filterByCategory = "";
      self.optionsSubCategories = [];
      self.filterBySubCategory = "";

      updateSelectInterlocks(self);
    },
    selectionCategory: function () {
      var self = this;
      self.optionsSubCategories = self.subcategories[self.filterByCategory] || [];

      // 親(Category)が変わったら子をリセット
      self.filterBySubCategory = "";

      updateSelectInterlocks(self);
    },
    gotoSearch: function() {
      var self = this;
      self.makeHashStr(self.pageCurrent);
      window.location.hash = "#p=1"+self.hashNotIncludePage;
    },
    checkHash:function(){
      const self = this;
      let prm = getParam();
      if (prm["p"] == null) {
        prm["p"] = 1;
      }
      self.pageCurrent = prm["p"];
      // URLハッシュの値を安全にデコードしてセット
      self.filterByArea        = prm["area"]        ? decodeURIComponent(prm["area"])        : "";
      self.filterByCategory    = prm["category"]    ? decodeURIComponent(prm["category"])    : "";
      self.filterBySubCategory = prm["subcategory"] ? decodeURIComponent(prm["subcategory"]) : "";
      self.filterByKeyword     = prm["keyword"]     ? decodeURIComponent(prm["keyword"])     : "";
      self.filterBy = prm["filterBy"];

      // ハッシュ読み込み後にも依存制御を反映
      updateSelectInterlocks(self);
    },  
    makeItemAr: function() {
      //ページに必要な10件の抽出
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
      self.hashNotIncludePage = "";

      if(self.filterBy!=""){
        self.hashNotIncludePage += "&filterby=" + self.filterBy;

        if(self.filterBy=="category"){
          // 誤プロパティ名を修正（filterByImportance/CVE → Area/SubCategory）
          if(self.filterByArea!=""){
            self.hashNotIncludePage += "&area=" + encodeURIComponent(self.filterByArea);
          }
          if(self.filterByCategory!=""){
            self.hashNotIncludePage += "&category=" + encodeURIComponent(self.filterByCategory);
          }
          if(self.filterBySubCategory!=""){
            self.hashNotIncludePage += "&subcategory=" + encodeURIComponent(self.filterBySubCategory);
          }
        }else{
          if(self.filterByKeyword!=""){
            self.hashNotIncludePage += "&keyword=" + encodeURIComponent(self.filterByKeyword);
          }
        }
      }
    },
    sortItems: function() {//絞り込み検索処理
      const self = this;
      //AREA
      let tempArray_area =[];
      let tempArea = decodeURI(self.filterByArea);
      if(self.filterByArea!=""){
        for (let i = 0; i < self.allItems.length; i++) {
          let tempItem = self.allItems[i];
          if(tempItem["area"].includes(tempArea)){
            tempArray_area.push(tempItem);
          }
        }
      }else{
        tempArray_area = self.allItems;
      }

      //CATEGORY
      let tempArray_category =[];
      let tempCategory = decodeURI(self.filterByCategory);
      if(self.filterByCategory!=""){
        for (let i = 0; i < tempArray_area.length; i++) {
          let tempItem = tempArray_area[i];
          if(tempItem["category"].includes(tempCategory)){
            tempArray_category.push(tempItem);
          }
        }
      }else{
        tempArray_category = tempArray_area;
      }

      //SUBCATEGORY
      let tempArray_subcategory =[];
      let tempSubCategory = decodeURI(self.filterBySubCategory);
      if(self.filterBySubCategory!=""){
        for (let i = 0; i < tempArray_category.length; i++) {
          let tempItem = tempArray_category[i];
          if(tempItem["subcategory"].includes(tempSubCategory)){
            tempArray_subcategory.push(tempItem);
          }
        }
      }else{
        tempArray_subcategory = tempArray_category;
      }

      //KEYWORD
      let tempArray_keyword =[];
      let tempKeyword = decodeURI(self.filterByKeyword);
      let filterByKeywordUpperCase = tempKeyword.toUpperCase();//すべて大文字に変換
      let keywordsArray = filterByKeywordUpperCase.split(/\s/);

      if(self.filterByKeyword!=""){
        for (let i = 0; i < tempArray_subcategory.length; i++) {
          let tempItem = tempArray_subcategory[i];
          let tempItemProductUpperCase = tempItem["product"].toUpperCase();
          let isKeyword = keywordsArray.some((value, index, array) => {
            return tempItemProductUpperCase.includes(value);
          });
          if(isKeyword){
            tempArray_keyword.push(tempItem);
          }
        }
      }else{
        tempArray_keyword = tempArray_subcategory;
      }

      
      self.searchResult = tempArray_keyword;
      //self.searchResult =[];
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
        tempObj["url"] = "#p=" + i + self.hashNotIncludePage;
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
        self.urlPrev ="#p=" +(self.pageCurrent - 1) +self.hashNotIncludePage;
        self.flgPrev = true;
      } else {
        self.flgPrev = false;
      }

      //NEXTボタン
      if (self.pageCurrent != self.totalPage) {
        self.urlNext = "#p=" + (self.pageCurrent + 1) + self.hashNotIncludePage;
        self.flgNext = true;
      } else {
        self.flgNext = false;
      }
      //最初と最後のボタン
      self.urlFirst = "#p=1" + self.hashNotIncludePage;
      self.urlLast = "#p=" + self.totalPage + self.hashNotIncludePage;
    },
    makeOption:function(){//セレクトオプションを作成
      const self = this;
      let tempOptionAreaAr=[];
      for(i=0; i<self.allItemsForCategory.length; i++){
        //Areaを追加
        tempArea = self.allItemsForCategory[i]["area"];
        if (tempOptionAreaAr.indexOf(self.allItemsForCategory[i]["area"]) == -1) {
          tempOptionAreaAr.push(tempArea);
        }
        //カテゴリを追加
        tempCategory = self.allItemsForCategory[i]["category"];
        if(!self.categories[tempArea]){
          self.categories[tempArea] = [];
        }
        tempTargetAr = self.categories[tempArea];
        if (tempTargetAr.indexOf(tempCategory) == -1) {
          self.categories[tempArea].push(tempCategory);
        }
        //サブカテゴリを追加
        tempSubCategory = self.allItemsForCategory[i]["subcategory"];
        if(!self.subcategories[tempCategory]){
          self.subcategories[tempCategory] = [];
        }
        tempTargetSubAr = self.subcategories[tempCategory];
        if (tempTargetSubAr.indexOf(tempSubCategory) == -1) {
          self.subcategories[tempCategory].push(tempSubCategory);
        }
      }
      self.optionsAreas = tempOptionAreaAr;
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

    let nowdate = new Date();
    let year = String(nowdate.getFullYear());
    let mon  = String(nowdate.getMonth() + 1);
    let date = String(nowdate.getDate());
    let random = String(Math.floor( Math.random() * 11 ));
    let dateParam = year+mon+date+random;
    let fileName = "https://vuls.ricoh.com/ja/prodinfolist.json?"+dateParam;
    let isLocal = (document.location.hostname == "127.0.0.1"
        || document.location.hostname == "stg-prv-wrc.scms.jp.ricoh.com"
        || document.location.hostname == "stg-prv-jrc.scms.jp.ricoh.com");
    //データロード
    var LIST_PRODUCTS_IDB_NAME = "vulinfoFolderHandleDB";
    var LIST_PRODUCTS_IDB_STORE = "handles";
    var LIST_PRODUCTS_IDB_KEY = "vulsRicohRoot";
    function openListProductsHandleDB() {
      return new Promise(function (resolve, reject) {
        var req = indexedDB.open(LIST_PRODUCTS_IDB_NAME, 1);
        req.onupgradeneeded = function () {
          req.result.createObjectStore(LIST_PRODUCTS_IDB_STORE);
        };
        req.onsuccess = function () { resolve(req.result); };
        req.onerror = function () { reject(req.error); };
      });
    }
    function saveListProductsRootHandle(handle) {
      return openListProductsHandleDB().then(function (db) {
        return new Promise(function (resolve, reject) {
          var tx = db.transaction(LIST_PRODUCTS_IDB_STORE, "readwrite");
          tx.objectStore(LIST_PRODUCTS_IDB_STORE).put(handle, LIST_PRODUCTS_IDB_KEY);
          tx.oncomplete = function () { resolve(); };
          tx.onerror = function () { reject(tx.error); };
        });
      });
    }
    function loadSavedListProductsRootHandle() {
      return openListProductsHandleDB().then(function (db) {
        return new Promise(function (resolve, reject) {
          var tx = db.transaction(LIST_PRODUCTS_IDB_STORE, "readonly");
          var req = tx.objectStore(LIST_PRODUCTS_IDB_STORE).get(LIST_PRODUCTS_IDB_KEY);
          req.onsuccess = function () { resolve(req.result || null); };
          req.onerror = function () { reject(req.error); };
        });
      });
    }
    function waitForUserClickToSelectFolderListProducts(message) {
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
    function pickAndSaveFolderListProducts() {
      return waitForUserClickToSelectFolderListProducts("ローカルのvuls.ricoh.comフォルダを選択")
        .then(function () {
          return window.showDirectoryPicker({ id: "vulsRicohRoot", mode: "read" });
        })
        .then(function (handle) {
          window.__vulsRicohRootHandle = handle;
          return saveListProductsRootHandle(handle).then(function () { return handle; });
        });
    }
    function getVulsRicohRootHandleListProducts() {
      if (window.__vulsRicohRootHandle) {
        return Promise.resolve(window.__vulsRicohRootHandle);
      }
      if (!window.showDirectoryPicker) {
        return Promise.reject(new Error("File System Access API is not supported in this browser"));
      }
      return loadSavedListProductsRootHandle()
        .catch(function () { return null; })
        .then(function (savedHandle) {
          if (!savedHandle) {
            return pickAndSaveFolderListProducts();
          }
          return savedHandle.queryPermission({ mode: "read" })
            .then(function (status) {
              if (status === "granted") {
                window.__vulsRicohRootHandle = savedHandle;
                return savedHandle;
              }
              return waitForUserClickToSelectFolderListProducts("vuls.ricoh.comフォルダへのアクセスを許可")
                .then(function () {
                  return savedHandle.requestPermission({ mode: "read" });
                })
                .then(function (result) {
                  if (result === "granted") {
                    window.__vulsRicohRootHandle = savedHandle;
                    return savedHandle;
                  }
                  return pickAndSaveFolderListProducts();
                });
            })
            .catch(function () {
              return pickAndSaveFolderListProducts();
            });
        });
    }
    function loadListProductsDataViaFolderHandle() {
      return getVulsRicohRootHandleListProducts()
        .then(function (rootHandle) {
          return rootHandle.getDirectoryHandle("ja");
        })
        .then(function (jaHandle) {
          return jaHandle.getFileHandle("prodinfolist.json");
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
    (isLocal ? loadListProductsDataViaFolderHandle() : axios.get(fileName))
      .then(function(response) {
        let tempData = response.data;
        //表示用データ作成
        let temp = [];
        
        temp.length = 0;
        
        let count = 0;
        for(i=0; i<tempData.length; i++){
          let areaProduct = tempData[i];
          for(s=0; s<areaProduct.categories.length; s++){
            let categoryProduct = areaProduct.categories[s];
            for(l=0; l<categoryProduct.subCategories.length; l++){
              let subcategoryProduct = categoryProduct.subCategories[l];
              for(n=0; n<subcategoryProduct.products.length; n++){
                let product = subcategoryProduct.products[n];
                let item = {};
                item["area"] = areaProduct.name;
                item["subcategory"] = subcategoryProduct.name;
                item["category"] = categoryProduct.name;
                item["product"] = product.name;
                item["id"] = product.id;
                if(temp[count] == undefined){
                  temp[count] = item;
                }
                count++;
              }
            }
          }
        }
        
        self.allItems = temp;

        let tempCategory = [];
        tempCategory.length = 0;
        let countCategory = 0;
        for(i=0; i<tempData.length; i++){
          let areaProduct = tempData[i];
          if(areaProduct.categories.length==0){//temporay
            let item = {};
            item["area"] = areaProduct.name;
            item["subcategory"] = "";
            item["category"] = "";
            item["product"] = "";
            item["id"] = "";
            if(tempCategory[countCategory] == undefined){
              tempCategory[countCategory] = item;
            }
            countCategory++;
          }else{
            for(s=0; s<areaProduct.categories.length; s++){
              let categoryProduct = areaProduct.categories[s];
              
              for(l=0; l<categoryProduct.subCategories.length; l++){
                let subcategoryProduct = categoryProduct.subCategories[l];
                
                //temporay
                let item = {};
                item["area"] = areaProduct.name;
                item["subcategory"] = subcategoryProduct.name;
                item["category"] = categoryProduct.name;
                item["product"] = "";
                item["id"] = "";
                if(tempCategory[countCategory] == undefined){
                  tempCategory[countCategory] = item;
                }
                countCategory++;
              }
            }
          }
        }
        self.allItemsForCategory = tempCategory;

        // オプションを作成 → ハッシュの値でセレクトへ反映（リセットしない）
        self.makeOption();
        applyHashToSelects(self);

        //絞り込み検索
        self.sortItems();

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
      });

    let offsetVar = $("#vulinfoApp").offset();
    let scrollPost = offsetVar.top;
    //Hash監視
    window.onhashchange = function() {
      $("html,body").animate(
        {
          scrollTop: scrollPost
        },
        1000,
        "linear"
      );
      $("#vulWrap_cover").css("display", "block");
      $("#vulWrap_cover").css("opacity", 100);

      setTimeout(function() {
        self.checkHash();
        // ハッシュ変更時もセレクトへ反映
        applyHashToSelects(self);
        self.makeHashStr(self.pageCurrent);
        self.sortItems();
        self.makeItemAr();
        self.getPageStartEnd();
        self.makePaging();
        updateSelectInterlocks(self); // ← 依存制御を最終同期
        self.hideCover();
      }, 600);
    };
  }
});

function getParam() {
  // URLのハッシュを取得（先頭の # を除去）
  var urlHash = location.hash.substring(1);
  var prm = {};

  if (urlHash) {
    // '&' 区切りだが、値の中に「生の &」が混入している可能性があるので、
    // 「キーがない断片」は直前の値に連結して救済する。
    var rawParts = urlHash.split("&");
    var pairs = [];
    var currentKey = null;
    var currentVal = "";

    for (var i = 0; i < rawParts.length; i++) {
      var part = rawParts[i];
      if (part.includes("=")) {
        // 直前のバッファを確定
        if (currentKey !== null) {
          pairs.push([currentKey, currentVal]);
        }
        var idx = part.indexOf("=");
        currentKey = part.slice(0, idx);
        currentVal = part.slice(idx + 1);
      } else {
        // "=&" で切れてしまった続きを連結（救済）
        if (currentKey !== null) {
          currentVal += "&" + part;
        }
      }
    }
    if (currentKey !== null) {
      pairs.push([currentKey, currentVal]);
    }

    // ペアをオブジェクトへ
    var pageNum;
    var filterArea = "";
    var filterCategory = "";
    var filterSubCategory = "";
    var filterKeyword = "";
    var filterBy = "";

    for (var j = 0; j < pairs.length; j++) {
      var k = pairs[j][0];
      var v = pairs[j][1];

      // 値は decodeURIComponent を試みる（壊れたエンコードでも落ちないよう try/catch）
      try { v = decodeURIComponent(v); } catch (e) {}

      if (k === "p") {
        pageNum = v;
      } else if (k === "area") {
        filterArea = v;
      } else if (k === "category") {
        filterCategory = v;
      } else if (k === "subcategory") {
        filterSubCategory = v;
      } else if (k === "keyword") {
        filterKeyword = v;
      } else if (k === "filterby") {
        filterBy = v;
      }
    }

    prm["p"] = pageNum;
    prm["area"] = filterArea;
    prm["category"] = filterCategory;
    prm["subcategory"] = filterSubCategory;
    prm["keyword"] = filterKeyword;
    prm["filterBy"] = filterBy;
  } else {
    // ハッシュなしの初期値
    prm["p"] = undefined;
    prm["area"] = "";
    prm["category"] = "";
    prm["subcategory"] = "";
    prm["keyword"] = "";
    prm["filterBy"] = "category";
  }

  // タブ切替（既存処理）
  if (prm["filterBy"] == "keyword") {
    $("#sortBox h3").removeClass("isOpen");
    $("#sortBox__keyword h3").addClass("isOpen");
  } else {
    $("#sortBox h3").addClass("isOpen");
    $("#sortBox__keyword h3").removeClass("isOpen");
  }

  return prm;
}