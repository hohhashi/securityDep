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
    isError:false,
    isName:false
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

      let fileDir = gID.split("-");
      let fileName = "https://vuls.ricoh.com/ja/advisory/"+fileDir[2]+"/"+gID+".json?"+dateParam;
      //let fileName = "/-/Media/Ricoh/Sites/jp_ricoh/security/products/vulnerabilities/data/advisory/"+fileDir[2]+"/"+gID+".json?"+dateParam;
      //データロード
      axios
      .get(fileName)
      .then(function(response) {
        self.item = response.data;
        console.log(fileName);
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
        //HISTORY
        for(i=0; i<self.item.history.length; i++){
          //最終更新日
          // tempUpdate = self.item.history[i]["updatedAt"];
          // let tempUpdateTS = Date.parse(tempUpdate);
          // let tempUpdateDT = new Date(tempUpdateTS);
          self.item.history[i]["date"] = self.item.history[i]["updatedAt"];
        }
        //modelのnameがあるかどうか？
        for(s=0; s<self.item.models.length; s++){
          if(self.item.models[s].name !=""){
            self.isName = true;
          }
        }
        console.log(self.isName);
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


