//2019.05.16

if (document.location.protocol == "file:") {
  alert(
    "ファイル直アクセスだと動きません。サーバーを起動してアクセスしてください"
  );
}



let gCurrentPage;
let gImportance;


var app = new Vue({
  el: "#vulinfoApp",
  data: {
    jsondata: "",
    allItems: [], //論理削除対象以外の全データ

    optionsInitialDay: [],
    optionsLastUpDay: [],

    filterByImportance:"",
    filterByID:"",
    filterByKeyword:"",
    filterBySeverity:"",
    filterByCVE:"",
    filterByJVN:"",
    filterByInitialDate:"",
    filterByLastUpDate:"",
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
    gotoSearch: function() {
      var self = this;
      self.makeHashStr();
      window.location.hash = "#p=1"+self.hashNotIncludePage;
    },
    checkHash:function(){
      const self = this;
      let prm = getParam();
      if (prm["p"] == null) {
        prm["p"] = 1;
      }
      self.pageCurrent = prm["p"];
      self.filterByImportance = prm["importance"];
      self.filterByID = prm["id"];
      self.filterByKeyword = prm["keyword"];
      self.filterBySeverity = prm["severity"];
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
      if(self.filterByImportance!=""){
        self.hashNotIncludePage += "&importance=" + self.filterByImportance;
      }
      if(self.filterByID!=""){
        self.hashNotIncludePage += "&id=" + self.filterByID;
      }
      if(self.filterByKeyword!=""){
        self.hashNotIncludePage += "&keyword=" + self.filterByKeyword;
      }
      if(self.filterBySeverity!=""){
        self.hashNotIncludePage += "&severity=" + self.filterBySeverity;
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

      //ID
      let tempArray_id =[];
      if(self.filterByID!=""){
        for (let i = 0; i < tempArray_importance.length; i++) {
          let tempItem = tempArray_importance[i];
          if(tempItem["id"].includes(self.filterByID)){
            tempArray_id.push(tempItem);
          }
        }
      }else{
        tempArray_id = tempArray_importance;
      }

      //KEYWORDS
      let tempArray_keyword =[];
      let filterByKeywordUpperCase = self.filterByKeyword.toUpperCase();//すべて大文字に変換
      let keywordsArray = filterByKeywordUpperCase.split(/\s/);
      if(self.filterByKeyword!=""){
        for (let i = 0; i < tempArray_id.length; i++) {
          let tempItem = tempArray_id[i];
          let tempItemTitleUpperCase = tempItem["title"].toUpperCase();
          //配列内のキーワードに一致する場合：true
          let isKeyword = keywordsArray.some((value, index, array) => {
            return tempItemTitleUpperCase.includes(value);
          });
          if(isKeyword){
            tempArray_keyword.push(tempItem);
          }
        }
      }else{
        tempArray_keyword = tempArray_id;
      }

      //SEVERITY
      let tempArray_severity =[];
      if(self.filterBySeverity!=""){
        for (let i = 0; i < tempArray_keyword.length; i++) {
          let tempItem = tempArray_keyword[i];
          let tempItemSeverityUpperCase = tempItem["severity"].toUpperCase();
          if(tempItemSeverityUpperCase.includes(self.filterBySeverity)){
            tempArray_severity.push(tempItem);
          }
        }
      }else{
        tempArray_severity = tempArray_keyword;
      }

      //CVE
      let tempArray_cve =[];
      if(self.filterByCVE!=""){
        for (let i = 0; i < tempArray_severity.length; i++) {
          let tempItem = tempArray_severity[i];
          for (let s = 0; s < tempItem["cve"].length; s++) {
            if(tempItem["cve"][s]["id"].includes(self.filterByCVE)){
              tempArray_cve.push(tempItem);
              break;
            }
          }
        }
      }else{
        tempArray_cve = tempArray_severity;
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
      // let tempArray_publish =[];
      // if(self.filterByInitialDate!=""){
      //   console.log(tempArray_jvn.length);
      //   console.log(self.filterByInitialDate);
      //   for (let i = 0; i < tempArray_jvn.length; i++) {
      //     let tempItem = tempArray_jvn[i];
      //     let tempUnixConditionBefore = new Date(Date.parse(self.filterByInitialDate+"-01"));
      //     console.log(Date.parse(self.filterByInitialDate+"-01"));
      //     tempUnixConditionBefore = tempUnixConditionBefore.getTime();

      //     let tempUnixConditionAfter = new Date(Date.parse(self.filterByInitialDate+"-01"));
      //     tempUnixConditionAfter.setMonth(tempUnixConditionAfter.getMonth() + 1);
      //     tempUnixConditionAfter = tempUnixConditionAfter.getTime();

      //     let tempUnix = new Date(Date.parse(tempItem["publishedAt"]));
      //     tempUnix = tempUnix.getTime();
      //     if(tempUnix > tempUnixConditionBefore && tempUnix < tempUnixConditionAfter){
      //       tempArray_publish.push(tempItem);
      //     }
      //   }
      // }else{
      //   tempArray_publish = tempArray_jvn;
      // }
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

      //PUBLISH
      // let tempArray_update =[];
      // if(self.filterByLastUpDate!=""){
      //   for (let i = 0; i < tempArray_publish.length; i++) {
      //     let tempItem = tempArray_publish[i];
      //     let tempUnixConditionBefore = new Date(Date.parse(self.filterByLastUpDate+"-01"));
      //     tempUnixConditionBefore = tempUnixConditionBefore.getTime();

      //     let tempUnixConditionAfter = new Date(Date.parse(self.filterByLastUpDate+"-01"));
      //     tempUnixConditionAfter.setMonth(tempUnixConditionAfter.getMonth() + 1);
      //     tempUnixConditionAfter = tempUnixConditionAfter.getTime();

      //     let tempUnix = new Date(Date.parse(tempItem["updatedAt"]));
      //     tempUnix = tempUnix.getTime();
      //     if(tempUnix > tempUnixConditionBefore && tempUnix < tempUnixConditionAfter){
      //       tempArray_update.push(tempItem);
      //     }
      //   }
      // }else{
      //   tempArray_update = tempArray_publish;
      // }
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
        self.urlPrev =
          "#p=" +
          (self.pageCurrent - 1) +
          self.hashNotIncludePage;
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
    hideCover: function() {
      $("#vulWrap_cover").animate({ opacity: 0 }, 400, function() {
        $("#vulWrap_cover").css("display", "none");
      });
    }
  },
  computed: {},
  mounted: function() {
    const self = this;
    self.checkHash();
    
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
        self.makeHashStr(self.pageCurrent);
        self.sortItems();
        self.makeItemAr();
        self.getPageStartEnd();
        self.makePaging();
        self.hideCover();
      }, 600);
    };

    //データロード
    let nowdate = new Date();
    let year = String(nowdate.getFullYear());
    let mon  = String(nowdate.getMonth() + 1);
    let date = String(nowdate.getDate());
    let random = String(Math.floor( Math.random() * 11 ));
    let dateParam = year+mon+date+random;
    let fileName;
    if (document.location.hostname == "127.0.0.1"
        || document.location.hostname == "stg-prv-wrc.scms.jp.ricoh.com") {
        fileName = "http://127.0.0.1:5500/vuls.ricoh.com/ja/vulinfolist.json?" + dateParam;
    } else {
        fileName = "https://vuls.ricoh.com/ja/vulinfolist.json?" + dateParam;
    }
    //let fileName = "/-/Media/Ricoh/Sites/jp_ricoh/security/products/vulnerabilities/data/vulinfolist.json?"+dateParam;
    axios
      .get(fileName)
      .then(function(response) {
        let tempData = response.data;
        //表示用データ作成
        self.allItems = tempData;
        for(i=0; i<self.allItems.length; i++){
          //最終更新日
          tempLastUpdate = self.allItems[i]["updatedAt"];
          let tempLastDate = tempLastUpdate.substr( 0, 10 );
          let tempLastTime = tempLastUpdate.substring(tempLastUpdate.length - 6);
          self.allItems[i]["lastUpdate"] = tempLastDate + tempLastTime;
          //発行日
          tempFirstEdition = self.allItems[i]["publishedAt"];
          let tempFirstDate = tempFirstEdition.substr( 0, 10 );
          let tempFirstTime = tempFirstEdition.substring(tempFirstEdition.length - 6);
          self.allItems[i]["firstEdition"] = tempFirstDate + tempFirstTime;
          //リンクURL
          self.allItems[i]["linkUrl"] = "/security/products/vulnerabilities/vul?id=" + self.allItems[i].id;
          //self.allItems[i]["linkUrl"] = "vul?id=" + self.allItems[i].id;
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
  }
});

function getParam() {
  // URLのハッシュを取得
  var urlHash = location.hash.substring(1);
  var prm = {};
  // URLにハッシュが存在する場合
  if (urlHash) {
    // 「&」が含まれている場合は「&」で分割
    var param = urlHash.split("&");
    // ハッシュを格納する用の配列を用意
    var pageNum;
    var filterImportance = "";
    var filterID = "";
    var filterKeyword = "";
    var filterSeveritye = "";
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
        filterID = paramItem[1];
      } else if (paramItem[0] == "importance") {
        filterImportance = paramItem[1];
      } else if (paramItem[0] == "keyword") {
        paramItem[1] = decodeURI(paramItem[1]);
        filterKeyword = paramItem[1];
      } else if (paramItem[0] == "severity") {
        filterSeveritye = paramItem[1];
      } else if (paramItem[0] == "cve") {
        filterCve = paramItem[1];
      } else if (paramItem[0] == "jvn") {
        filterJvn = paramItem[1];
      } else if (paramItem[0] == "publish") {
        filterFday = paramItem[1];
      } else if (paramItem[0] == "update") {
        filterLday = paramItem[1];
      }
    }
    //ハッシュの配列をオブジェクトに格納
    prm["p"] = pageNum;
    prm["importance"] = filterImportance;
    prm["id"] = filterID;
    prm["keyword"] = filterKeyword;
    prm["severity"] = filterSeveritye;
    prm["cve"] = filterCve;
    prm["jvn"] = filterJvn;
    prm["publish"] = filterFday;
    prm["update"] = filterLday;
  } else {
    //ハッシュなし
    prm["p"] = pageNum;
    prm["importance"] = "";
    prm["id"] = "";
    prm["keyword"] = "";
    prm["severity"] = "";
    prm["cve"] = "";
    prm["jvn"] = "";
    prm["publish"] = "";
    prm["update"] = "";
  }
  return prm;
}


